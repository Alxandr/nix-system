# File truncation safety

If a file unexpectedly becomes zero-length during editing, stop immediately.
Do not attempt recovery or further edits. Tell the user which file was
truncated and wait for them to inspect the situation.
