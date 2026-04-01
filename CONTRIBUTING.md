# Contributing

## Development workflow

1. Make focused changes with tests.
2. Run:
   - `haxe build.hxml`
   - `haxe test.hxml`
3. Add or update fixtures in `test/fixtures/` when parser or serializer behavior changes.
4. Keep documentation and changelog entries aligned with any public API or format-support change.

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
