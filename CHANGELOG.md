# Changelog

## Unreleased

- Bumped the package metadata version to `0.3.0` and refreshed the release
  wording for the current text-plus-image scope
- Refreshed `haxelib.json` to advertise the current text and texture format
  scope more accurately
- Added a canonical image round-trip example showing `TextureData`, `TgaCodec`,
  and texture-compression support lookup in one place
- Added additional image edge-case coverage for unsupported BMP info-header
  sizes, truncated TGA RLE packets, unsupported TIFF planar configuration, and
  unsupported PVR pixel-format metadata
- Added image contract tests for unsupported BMP compression, DDS fourCC,
  KTX array textures, PVR multi-surface inputs, TIFF compression, and TGA
  color-mapped headers
- Tightened the README image support matrix to spell out the supported subset
  per format
- Added image-suite runner wiring to `TestMain` and covered TGA RLE round-trips
  with a fixture-backed regression test
- Added simple TGA RLE packet support as a pure-Haxe low-complexity texture
  path
- Documented the image-branch scope in the README as GPU containers plus small
  uncompressed baselines
- Moved all text formats under `digigun.formats.text.<format>` while keeping
  each format’s internal structure intact
- Relocated text fixtures and tests under `test/fixtures/text/` and
  `test/test/text/`
- Tightened TOML and YAML malformed nested delimiter rejection in the flow and
  inline collection scanners
- Clarified TOML, YAML, and HCL malformed-collection rejection behavior in the
  README

- Added EditorConfig parsing, writing, and document helpers as a thin
  specialization over the INI document model
- Added fixture-backed EditorConfig parse, round-trip, and invalid-input tests
- Documented the supported EditorConfig subset in the README

- Began `text-hardening/ini-env-properties`
- Fixed INI writer quoting so string values that look like booleans or numbers
  round-trip as strings
- Fixed `.properties` delimiter detection so escaped `=` and `:` remain part of
  the key or value
- Fixed `.properties` writing so literal `=` and `:` round-trip correctly
- Added `.env` coverage for quoted empty values and literal `#` handling
- Added malformed INI section-header and malformed exported `.env` entry
  coverage
- Clarified INI, `.env`, and `.properties` subset behavior in the README

- Began `text-hardening/msgpack-ndjson-csv`
- Added nested MessagePack structure coverage and unsupported integer-range
  coverage
- Fixed MessagePack `float64` decoding to reconstruct doubles correctly
- Added NDJSON coverage for blank lines and mixed primitive/object records
- Added CSV coverage for alternate delimiters and trailing empty cells
- Tightened CSV parsing to reject trailing characters after a closing quoted
  cell
- Added MessagePack rejection coverage for truncated nested array and map
  payloads
- Added NDJSON line-location coverage for invalid records after blank lines
- Added CSV rejection coverage for quote usage after leading whitespace
- Clarified MessagePack string-key helper scope versus generic binary map keys
- Clarified NDJSON blank-line and trailing-newline behavior
- Clarified the strict CSV quoted-cell subset in the README

- Added TOML hardening coverage for nested inline tables and nested array/object
  combinations inside the supported inline-table subset
- Added YAML hardening coverage for nested flow collections and fixed scalar
  writer quoting for strings that would otherwise round-trip as non-strings
- Added YAML rejection coverage for trailing root content and malformed flow
  collection syntax, and now reject malformed flow-looking scalars explicitly
- Added HCL hardening coverage for nested objects, nested arrays, and trimmed
  heredoc parsing
- Added rejection coverage for malformed TOML inline tables and malformed
  nested HCL object structure
- Restricted TOML parsing to the documented bare-key subset for properties,
  inline-table fields, and table names
- Added YAML rejection coverage for mixed flow/block structure misuse
- Added YAML rejection coverage for unexpected sequence indentation
- Added HCL rejection coverage for malformed array delimiters
- Added HCL rejection coverage for malformed object delimiters

## 0.2.0

- Stabilized the text-format milestone covering INI, TOML, CSV, `.properties`,
  `.env`, YAML, MessagePack, NDJSON, and HCL2
- Added TOML inline table parsing, writing, and value helpers
- Added YAML flow collection parsing and document-level root property helpers
- Added HCL document-level editing helpers and `:` support in object fields
- Added MessagePack document-level root property helpers
- Expanded fixture-backed edge coverage for TOML, YAML, and HCL
- Added persistent project memory under `./.codex` for future Codex sessions

## 0.1.0

- Initial release of `digigun.formats.hx`
- Added strongly typed core reader, writer, and codec abstractions
- Added built-in support for INI, TOML, CSV, `.properties`, `.env`, YAML, MessagePack, NDJSON, and an HCL2 subset
- Added mutable editing APIs across document models
- Added fixture-backed parser and serializer tests, including edge-case fixtures
- Added eval and JavaScript compile verification
- Added compatibility, contribution, and release-process documentation
