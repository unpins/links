# Changelog

## [Unreleased]

### Fixed

- The Windows build now looks for a CA trust store under `C:\ssl`. It pointed
  at `/etc/ssl`, a path that cannot exist on Windows, so turning the bundled
  Mozilla CA bundle off with `-ssl.builtin-certificates 0` left the browser
  with nowhere to read certificates from.
