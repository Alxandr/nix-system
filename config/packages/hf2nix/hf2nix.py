#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path
from typing import cast

from huggingface_hub import HfApi, hf_hub_url


@dataclass(frozen=True)
class ModelRef:
	repo_id: str
	quant: str | None

	@staticmethod
	def parse(model_ref: str) -> ModelRef:
		repo_id, separator, quant = model_ref.partition(":")
		if repo_id == "":
			msg = "modelRef must include a Hugging Face repo id"
			raise ValueError(msg)
		if "/" not in repo_id:
			msg = "modelRef must include a namespace and model name, for example owner/model"
			raise ValueError(msg)

		return ModelRef(repo_id=repo_id, quant=quant if separator else None)

	@property
	def ref(self) -> str:
		if self.quant is None:
			return self.repo_id
		return f"{self.repo_id}:{self.quant}"


@dataclass(frozen=True)
class Args:
	model_ref: ModelRef
	output: str
	mmproj: bool
	dry_run: bool

	@staticmethod
	def parse(argv: list[str] | None = None) -> Args:
		parser = argparse.ArgumentParser(
			prog="hf2nix",
			description="Generate Nix expressions for Hugging Face model references.",
		)
		_ = parser.add_argument(
			"modelRef",
			help="Hugging Face model reference, for example unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q8_K_XL",
		)
		_ = parser.add_argument(
			"-o",
			"--output",
			default="-",
			help="Output path. Defaults to '-' for stdout. Paths without a suffix are treated as directories.",
		)
		_ = parser.add_argument(
			"--mmproj",
			dest="mmproj",
			action="store_true",
			default=True,
			help="Download a multimodal projector file if available. Enabled by default.",
		)
		_ = parser.add_argument(
			"--no-mmproj",
			dest="mmproj",
			action="store_false",
			help="Do not download a multimodal projector file.",
		)
		_ = parser.add_argument(
			"--dry-run",
			action="store_true",
			help="Do not download files. Use dry-run placeholders for local paths and hashes.",
		)

		parsed_args = cast("dict[str, object]", vars(parser.parse_args(argv)))
		model_ref = parsed_args["modelRef"]
		output = parsed_args["output"]
		mmproj = parsed_args["mmproj"]
		dry_run = parsed_args["dry_run"]

		if not isinstance(model_ref, str):
			parser.error("modelRef must be a string")
		if not isinstance(output, str):
			parser.error("--output must be a string")
		if not isinstance(mmproj, bool):
			parser.error("--mmproj must be a boolean")
		if not isinstance(dry_run, bool):
			parser.error("--dry-run must be a boolean")

		try:
			parsed_model_ref = ModelRef.parse(model_ref)
		except ValueError as error:
			parser.error(str(error))

		return Args(
			model_ref=parsed_model_ref,
			output=output,
			mmproj=mmproj,
			dry_run=dry_run,
		)


@dataclass(frozen=True)
class LocalModel:
	model_ref: ModelRef
	rev: str
	model: str
	mmproj: str | None
	files: tuple[LocalModelFile, ...]


@dataclass(frozen=True)
class LocalModelFile:
	rel_path: str
	path: Path
	url: str
	hash: str

	@staticmethod
	def prefetch(
		repo_id: str,
		revision: str,
		rel_path: str,
		dry_run: bool,
	) -> LocalModelFile:
		url = hf_hub_url(
			repo_id=repo_id,
			filename=rel_path,
			repo_type="model",
			revision=revision,
		)
		if dry_run:
			placeholder = f"dry-run/{Path(rel_path).name}"
			return LocalModelFile(
				rel_path=rel_path,
				path=Path(placeholder),
				url=url,
				hash=placeholder,
			)

		prefetch_result = nix_prefetch_file(url=url, name=Path(rel_path).name)
		return LocalModelFile(
			rel_path=rel_path,
			path=prefetch_result.store_path,
			url=url,
			hash=prefetch_result.hash,
		)


@dataclass(frozen=True)
class NixPrefetchResult:
	store_path: Path
	hash: str


@dataclass(frozen=True)
class GgufSplitInfo:
	prefix: str
	tag: str
	index: int
	count: int


def output_filename(model_ref: str) -> str:
	base = re.sub(r"[^A-Za-z0-9._-]+", "-", model_ref).strip("-")
	return f"{base or 'model'}.nix"


def resolve_output_path(output: str, model_ref: str) -> Path | None:
	if output == "-":
		return None

	output_path = Path(output)
	if output_path.suffix == "" or output_path.is_dir():
		return output_path / output_filename(model_ref)

	return output_path


def nix_prefetch_file(url: str, name: str) -> NixPrefetchResult:
	result = subprocess.run(
		["nix", "store", "prefetch-file", "--json", "--name", name, url],
		check=True,
		capture_output=True,
		text=True,
	)
	data = json.loads(result.stdout)
	if not isinstance(data, dict):
		msg = "nix store prefetch-file returned invalid JSON"
		raise ValueError(msg)

	store_path = data.get("storePath")
	file_hash = data.get("hash")
	if not isinstance(store_path, str):
		msg = "nix store prefetch-file did not return a storePath"
		raise ValueError(msg)
	if not isinstance(file_hash, str):
		msg = "nix store prefetch-file did not return a hash"
		raise ValueError(msg)

	return NixPrefetchResult(store_path=Path(store_path), hash=file_hash)


def gguf_split_info(path: str) -> GgufSplitInfo | None:
	path_without_suffix = path.removesuffix(".gguf")
	if path_without_suffix == path:
		return None

	index = 1
	count = 1
	prefix = path_without_suffix
	split_match = re.fullmatch(r"(.+)-([0-9]{5})-of-([0-9]{5})", prefix, re.I)
	if split_match is not None:
		prefix = split_match.group(1)
		index = int(split_match.group(2))
		count = int(split_match.group(3))

	tag_match = re.search(r"[-.]([A-Z0-9_]+)$", prefix, re.I)
	tag = tag_match.group(1).upper() if tag_match is not None else ""

	return GgufSplitInfo(prefix=prefix, tag=tag, index=index, count=count)


def is_model_gguf(path: str) -> bool:
	file_name = Path(path).name
	return (
		file_name.endswith(".gguf")
		and "mmproj" not in file_name
		and "imatrix" not in file_name
	)


def is_mmproj_gguf(path: str) -> bool:
	return path.endswith(".gguf") and "mmproj" in path


def matches_quant(path: str, quant: str) -> bool:
	return re.search(re.escape(quant) + r"[.-]", path, re.I) is not None


def quant_bits(path: str) -> int:
	split = gguf_split_info(path)
	if split is None:
		return 0

	match = re.search(r"[0-9]+", split.tag)
	return int(match.group(0)) if match is not None else 0


def find_best_model(repo_files: list[str], quant: str | None) -> str | None:
	tags = [quant] if quant is not None else ["Q4_K_M", "Q8_0"]

	for tag in tags:
		for path in repo_files:
			split = gguf_split_info(path)
			if split is None or not is_model_gguf(path) or not matches_quant(path, tag):
				continue
			if split.count > 1 and split.index != 1:
				continue
			return path

	if quant is not None:
		return None

	for path in repo_files:
		split = gguf_split_info(path)
		if split is None or not is_model_gguf(path):
			continue
		if split.count > 1 and split.index != 1:
			continue
		return path

	return None


def split_files(repo_files: list[str], primary: str) -> tuple[str, ...]:
	primary_split = gguf_split_info(primary)
	if primary_split is None or primary_split.count <= 1:
		return (primary,)

	result: list[str] = []
	for path in repo_files:
		split = gguf_split_info(path)
		if (
			split is not None
			and split.prefix == primary_split.prefix
			and split.count == primary_split.count
		):
			result.append(path)

	return tuple(sorted(result))


def find_best_mmproj(repo_files: list[str], primary: str) -> str | None:
	best_path: str | None = None
	best_depth = 0
	best_diff = 0
	model_bits = quant_bits(primary)
	model_parts = primary.split("/")
	model_dir = model_parts[:-1]

	for path in repo_files:
		if not is_mmproj_gguf(path):
			continue

		mmproj_parts = path.split("/")
		mmproj_dir = mmproj_parts[:-1]
		common_depth = 0

		for model_part, mmproj_part in zip(model_dir, mmproj_dir, strict=False):
			if model_part != mmproj_part:
				break
			common_depth += 1

		if common_depth != len(mmproj_dir):
			continue

		diff = abs(quant_bits(path) - model_bits)
		if (
			best_path is None
			or common_depth > best_depth
			or (common_depth == best_depth and diff < best_diff)
		):
			best_path = path
			best_depth = common_depth
			best_diff = diff

	return best_path


def select_quant_files(
	repo_files: list[str],
	quant: str | None,
	download_mmproj: bool,
) -> tuple[str, ...]:
	primary = find_best_model(repo_files, quant)
	if primary is None:
		msg = "no GGUF model files found in repo"
		if quant is not None:
			msg = f"no GGUF model files in repo matched quant {quant!r}"
		raise ValueError(msg)

	files = list(split_files(repo_files, primary))
	if download_mmproj:
		mmproj = find_best_mmproj(repo_files, primary)
		if mmproj is not None:
			files.append(mmproj)

	return tuple(files)


def find_model_file(files: tuple[LocalModelFile, ...]) -> LocalModelFile:
	for file in files:
		if is_model_gguf(file.rel_path):
			return file

	msg = "no local model file selected"
	raise ValueError(msg)


def find_mmproj_file(files: tuple[LocalModelFile, ...]) -> LocalModelFile | None:
	for file in files:
		if is_mmproj_gguf(file.rel_path):
			return file

	return None


def download_model(
	model_ref: ModelRef,
	download_mmproj: bool,
	dry_run: bool,
) -> LocalModel:
	api = HfApi()
	model_info = api.model_info(model_ref.repo_id)
	revision = model_info.sha
	if revision is None:
		msg = f"could not resolve revision for {model_ref.repo_id}"
		raise ValueError(msg)

	repo_files = api.list_repo_files(model_ref.repo_id, repo_type="model")
	selected_files = select_quant_files(repo_files, model_ref.quant, download_mmproj)

	max_prefetch_workers = min(4, len(selected_files))
	with ThreadPoolExecutor(max_workers=max_prefetch_workers) as executor:
		files = tuple(
			executor.map(
				lambda rel_path: LocalModelFile.prefetch(
					repo_id=model_ref.repo_id,
					revision=revision,
					rel_path=rel_path,
					dry_run=dry_run,
				),
				selected_files,
			),
		)

	model_file = find_model_file(files)
	mmproj_file = find_mmproj_file(files)

	return LocalModel(
		model_ref=model_ref,
		rev=revision,
		model=str(model_file.rel_path),
		mmproj=str(mmproj_file.rel_path) if mmproj_file is not None else None,
		files=files,
	)


def render(local_model: LocalModel) -> str:
	owner, repo = local_model.model_ref.repo_id.split("/", maxsplit=1)
	quant = local_model.model_ref.quant or ""
	files = "\n".join(render_file(file) for file in local_model.files)
	attrs = [
		"{",
		f"  owner = {nix_string(owner)};",
		f"  repo = {nix_string(repo)};",
		f"  quant = {nix_string(quant)};",
		f"  rev = {nix_string(local_model.rev)};",
		f"  model = {nix_string(local_model.model)};",
	]
	if local_model.mmproj is not None:
		attrs.append(f"  mmproj = {nix_string(local_model.mmproj)};")
	attrs.extend(
		[
			"  files = [",
			files,
			"  ];",
			"}",
			"",
		],
	)

	return nixfmt(
		"\n".join(attrs),
	)


def render_file(file: LocalModelFile) -> str:
	return " ".join(
		(
			"    {",
			f"path = {nix_string(file.rel_path)};",
			f"url = {nix_string(file.url)};",
			f"hash = {nix_string(file.hash)};",
			"}",
		),
	)


def nix_string(value: str) -> str:
	return json.dumps(value)


def nixfmt(content: str) -> str:
	result = subprocess.run(
		["nixfmt", "--filename", "hf2nix-output.nix"],
		input=content,
		check=True,
		capture_output=True,
		text=True,
	)
	return result.stdout


def write_output(output_path: Path | None, content: str) -> None:
	if output_path is None:
		_ = sys.stdout.write(content)
		return

	output_path.parent.mkdir(parents=True, exist_ok=True)
	_ = output_path.write_text(content, encoding="utf-8")


def main(argv: list[str] | None = None) -> int:
	args = Args.parse(argv)
	local_model = download_model(args.model_ref, args.mmproj, args.dry_run)
	output_path = resolve_output_path(args.output, args.model_ref.ref)
	write_output(output_path, render(local_model))
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
