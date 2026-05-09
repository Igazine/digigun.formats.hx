# Project Assessment

## Project

- Name: `digigun.formats.hx`
- Repository: `https://github.com/igazine/digigun.formats.hx`
- Language: Haxe
- Package type: `haxelib`

## Core architecture

- The project centers on `FormatReader`, `FormatWriter`, and `FormatCodec`
  interfaces for typed parsing and serialization.
- Each format has a strongly typed document/value model with mutable editing
  helpers rather than a global runtime registry.
- Public error handling goes through `FormatResult`, `FormatError`,
  `FormatErrorCode`, and `FormatLocation`.
- Tests are fixture-backed where parser or serializer output is a user-visible
  contract.

## Text-format surface included in the `v0.2.0` milestone

- INI
- TOML
- CSV
- `.properties`
- `.env`
- YAML
- MessagePack
- NDJSON
- HCL2

## Text-format assessment at milestone time

- The core text-format suite builds and passes through `haxe build.hxml` and
  `haxe test.hxml`.
- TOML now supports inline tables, including parsing, mutation, and
  deterministic writing for the supported subset.
- YAML now supports flow collections and document-level root property helpers.
- HCL2 now accepts `:` as well as `=` in object fields and exposes root-level
  editing helpers on `HclDocument`.
- MessagePack exposes document-level root property helpers for map-backed
  documents.
- Fixture helpers now include binary fixture loading support, but the `v0.2.0`
  milestone intentionally scopes release claims to text formats.

## Milestone boundary

- Version/tag target: `v0.2.0`
- Milestone meaning: first major development milestone for the text-format
  surface
- Explicitly out of scope for this milestone: image and texture formats,
  codecs, tests, and release claims

## Important repo facts

- The repository contains untracked image-related work under
  `src/digigun/formats/image` and `test/test/image`, but that work is not part
  of the `v0.2.0` milestone.
- Shared docs and test wiring were adjusted so the milestone remains text-only.
- CI currently runs `haxe build.hxml` and `haxe test.hxml` on GitHub Actions.

## Documentation policy captured during this session

- Public docs must describe only the formats intentionally included in the
  current milestone.
- Supported subsets should be explicit.
- `./.codex` is part of the durable project memory and should be maintained
  when milestones shift.
