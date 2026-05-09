# Candidate Next Steps

## Highest-priority follow-ups after `v0.2.0`

- Continue text hardening in this order:
  1. `text-hardening/toml-yaml-hcl`
  2. `text-hardening/msgpack-ndjson-csv`
  3. `text-hardening/ini-env-properties`
- Reassess the untracked image/texture work only after the text-format
  hardening sequence reaches a good stopping point.

## Current branch notes

- `text-hardening/toml-yaml-hcl` has an initial green pass.
- That pass added:
  - nested TOML inline-table coverage
  - nested YAML flow-collection coverage
  - YAML writer quoting for strings that resemble booleans, nulls, numbers, or
    flow collections
  - HCL nested object/array and trimmed heredoc coverage
- Remaining likely opportunities in this branch:
  - TOML invalid inline-table and delimiter edge rejection
  - YAML indentation/mixed-structure rejection coverage
  - HCL malformed nested-structure rejection coverage

## Known deferred work

- Image and texture codec integration
- Image-related examples and documentation
- JSON5 as a low-priority future consideration only if a concrete use case
  emerges
- Archive/compression-related formats only after the separate compression
  project is ready for reuse here
