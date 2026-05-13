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

## Text-format surface included in the `0.3.0` release

- INI
- EditorConfig
- TOML
- CSV
- `.properties`
- `.env`
- YAML
- MessagePack
- NDJSON
- HCL2

## Image-format surface in the current checkpoint

- DDS
- KTX
- PVR
- BMP
- TIFF
- TGA
- PPM/PGM
- RAW

## Image-format assessment at checkpoint time

- The image branch is intentionally narrower than a generic image library.
- Formats that require general-purpose compression are deferred.
- TGA RLE is allowed because it is simple, local to the format, and does not
  force an external codec dependency.
- TIFF is kept as an uncompressed baseline only.
- The public README now lists the supported subset per format.
- A canonical image example now demonstrates `TextureData`, `TgaCodec`, and
  compression planning in one place.

## Text-format assessment at release time

- The core text-format suite builds and passes through `haxe build.hxml` and
  `haxe test.hxml`.
- EditorConfig has been added as a thin specialization over the existing INI
  document model, with fixture-backed parse, round-trip, and invalid-input
  coverage.
- TOML and YAML now reject malformed nested closing delimiters inside flow and
  inline collection scanners, with regression coverage for the unsupported
  cases.
- TOML now supports inline tables, including parsing, mutation, and
  deterministic writing for the supported subset.
- YAML now supports flow collections and document-level root property helpers.
- HCL2 now accepts `:` as well as `=` in object fields and exposes root-level
  editing helpers on `HclDocument`.
- MessagePack exposes document-level root property helpers for map-backed
  documents.
- Fixture helpers now include binary fixture loading support, and the `0.3.0`
  release scope includes both text and image formats.

## Release boundary

- Version target: `0.3.0`
- Release meaning: first stable package release covering text and image format
  surfaces
- Explicitly out of scope for this release: future image formats, compression
  libraries, and broadening the current texture subset

## Important repo facts

- The repository now contains committed image-related work under
  `src/digigun/formats/image` and `test/test/image`, and that work is part of
  the `0.3.0` release.
- Shared docs and test wiring were adjusted so the release remains explicit
  about its text and image subsets.
- CI currently runs `haxe build.hxml` and `haxe test.hxml` on GitHub Actions.
- The current active branch is `master`, with the image branch fully merged
  and the latest work checkpoint focused on stabilization docs/examples.
- The text-format packages now live under `digigun.formats.text.<format>`.
- After `0.3.0`, text hardening continued on dedicated branches:
  - `text-hardening/toml-yaml-hcl`
  - `text-hardening/msgpack-ndjson-csv`
  - `text-hardening/ini-env-properties`

## Documentation policy captured during this session

- Public docs must describe only the formats intentionally included in the
  current milestone.
- Supported subsets should be explicit.
- `./.codex` is part of the durable project memory and should be maintained
  when milestones shift.
- Prefer thin specializations over duplicating parser logic when a format can
  reuse an existing document model without violating the pure-Haxe constraint.
- When hardening parsers, add regression tests for malformed nested delimiters
  before changing the scanners so the failure mode stays explicit.
- For image formats, prefer small contract tests that mutate a valid header or
  payload into a rejected subset case instead of inventing synthetic bad
  buffers from scratch.
- Canonical examples are useful when the supported subset is already stable and
  the remaining task is making the public path obvious.
