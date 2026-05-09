# Changelog

## Unreleased

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
