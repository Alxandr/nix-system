---
name: dotnet
description: Work on, analyze, and modify .NET codebases. Use when a prompt involves C#, .NET, ASP.NET Core, solution or project files, or changes inside a .NET repository.
---

# Dotnet

- Before starting work, make sure to restore the solution using `dotnet restore` to ensure all dependencies are available.
- Find the rootmost `.sln` file in the repository before doing deeper analysis.
- If the Glider tools mentioned bellow are not available, stop your work and ask the user to install them.
- Load that solution with Glider `load` and use it as the semantic workspace for follow-up work.
- If no `.sln` exists, fall back to the rootmost `.csproj`.
- Use the `get_diagnostics` tool to get diagnostics for the loaded solution. Using `dotnet build` will not always output warnings due to incremental builds, so `get_diagnostics` is more reliable for this purpose.
- Glider has a tendency to be too caching, so if you are not getting expected results, try re-loading the solution.
- When modifying code, make sure to run the `format_document` tool afterwards.
- Prefer the `view_external_definition` tool for understanding external APIs over web searches.
- Read global.json if it exists to determine if the project is using `Microsoft.Testing.Platform` as the test runner, which affect the flags to use when running tests.