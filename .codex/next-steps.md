# Candidate Next Steps

## Highest-priority follow-ups after `v0.2.0`

- Reassess the untracked image/texture work and decide whether it belongs in a
  dedicated branch, a follow-up milestone, or a narrower extraction.
- Expand text-format edge coverage where current subsets are still intentionally
  limited.
- Add stronger multi-target verification if cross-target support needs to be
  enforced more strictly than interpreter-only CI.

## Questions for the next joint investigation

- Which text-format subset gaps matter most to intended users?
- Should the next milestone deepen text correctness, broaden examples, or move
  into image/texture format work?
- Does the repo need a clearer release discipline for staging unrelated work in
  parallel?

## Known deferred work

- Image and texture codec integration
- Image-related examples and documentation
- Any automated compatibility checks beyond the current build/test workflow
