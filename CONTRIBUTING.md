# Contributing

## Development workflow

1. Make focused changes with tests.
2. Run:
   - `haxe build.hxml`
   - `haxe test.hxml`
3. Add or update fixtures in `test/fixtures/` when parser or serializer behavior changes.
4. Keep `README.md`, `CHANGELOG.md`, `haxelib.json`, and any relevant
   `./.codex` project memory files aligned with public API or format-support
   changes.

## Fixture policy

- Prefer fixture-backed tests for parser and serializer behavior.
- Treat fixture outputs as intentional contracts for current writer formatting.
- When serializer output changes, update fixtures only when the new output is clearly preferable and documented.

## Format support philosophy

This library favors practical, writable subsets over incomplete attempts at full specification coverage. New format work should:

- document the supported subset explicitly
- avoid hidden `Dynamic`-heavy behavior unless delegation to an external standard-library type is intentional
- preserve cross-target compatibility
- include mutable editing coverage where the format model supports it

## Project memory

- Use `./.codex/` for durable project notes that should survive Codex restarts.
- Prefer structured Markdown with clear sections for assessment, decisions,
  current status, deferred work, and next steps.
- Update the relevant `./.codex` files whenever a milestone meaningfully changes
  the project state or development priorities.
