# Candidate Next Steps

## Highest-priority follow-ups on `master`

- Decide whether to cut a release tag from the current merged state or keep
  iterating with small metadata/docs cleanup only.
- Keep the current image subset explicit in docs and tests.
- Perform only small cleanup changes from here, not new scope.
- BC4 / BC5 and RG8 are the current image extension checkpoint; any further
  image work should stay within the same lightweight texture-family policy.
- ETC2 RGBA8 and EAC R11/RG11 are now included in that checkpoint for
  Khronos/WebGL-style targets.

## Current branch notes

- The current image checkpoint added:
  - DDS, KTX, PVR, BMP, TIFF, TGA, PPM/PGM, and RAW source trees
  - texture support metadata and block-format planning helpers
  - fixture-backed parser/writer tests and a dedicated image test runner
  - README and changelog documentation for the GPU-texture-first scope
  - a canonical image round-trip example
- TGA now has optional simple RLE support.
- The current hardening slice added contract tests for unsupported BMP
  compression, DDS fourCC variants, KTX array textures, PVR multi-surface
  inputs, TIFF compression, and TGA color-mapped headers.
- The supported subset should remain narrow and explicit.

## Known deferred work

- General-purpose compression-dependent image formats, especially PNG
- Any image codec work that would require external compression libraries
- Broadening the image branch beyond the current GPU/container-oriented subset
- Large new image families until the BC4 / BC5 hardening pass is considered
  stable
- JSON5 remains a low-priority future consideration only if a concrete use case
  emerges
