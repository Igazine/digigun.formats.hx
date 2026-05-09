# Changelog

## Unreleased

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
