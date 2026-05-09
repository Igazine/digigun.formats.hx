# Candidate Next Steps

## Highest-priority follow-ups after `v0.2.0`

- Continue text hardening in this order:
  1. `text-hardening/toml-yaml-hcl`
  2. `text-hardening/msgpack-ndjson-csv`
  3. `text-hardening/ini-env-properties`
- Reassess the untracked image/texture work only after the text-format
  hardening sequence reaches a good stopping point.

## Current branch notes

- `text-hardening/msgpack-ndjson-csv` is now active.
- The first pass on this branch added:
  - nested MessagePack structure coverage
  - MessagePack unsupported integer-range coverage
  - a real MessagePack float64 decode fix
  - NDJSON blank-line and mixed primitive/object coverage
  - CSV alternate-delimiter and trailing-empty-cell coverage
  - a CSV parser fix for trailing characters after closing quotes
- Remaining likely opportunities on this branch:
  - MessagePack malformed nested payload rejection coverage
  - NDJSON invalid-line isolation and line-number precision checks
  - CSV whitespace/quote-boundary subset clarification and rejection coverage

## Current branch notes

- `text-hardening/toml-yaml-hcl` has an initial green pass.
- The completed passes on this branch added:
  - nested TOML inline-table coverage
  - nested YAML flow-collection coverage
  - YAML writer quoting for strings that resemble booleans, nulls, numbers, or
    flow collections
  - HCL nested object/array and trimmed heredoc coverage
  - TOML malformed inline-table rejection coverage
  - TOML bare-key subset enforcement for property keys, inline-table keys, and
    table names
  - YAML trailing-root-content rejection coverage
  - YAML malformed flow-syntax rejection and parser tightening
  - YAML mixed flow/block misuse rejection coverage
  - HCL malformed nested-object rejection coverage
  - HCL malformed array-delimiter rejection coverage
- Remaining likely opportunities in this branch:
  - likely branch wrap-up after the README subset wording refresh and the
    latest YAML/HCL delimiter coverage
  - optional extra TOML invalid-structure cases if a concrete gap appears

## Known deferred work

- Image and texture codec integration
- Image-related examples and documentation
- JSON5 as a low-priority future consideration only if a concrete use case
  emerges
- Archive/compression-related formats only after the separate compression
  project is ready for reuse here
