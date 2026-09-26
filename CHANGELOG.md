# Changelog

## [Unreleased]

## [2.30-2] - 2026-09-26

### Added

- Pages served with `Content-Encoding: br` (brotli) or `zstd` are now
  decompressed, on every platform. Both are widely used by web servers today;
  links asked for neither, so such a page arrived as gzip at best.

### Fixed

- The Windows build never handled gzip, the compression nearly every web
  server uses. It did not ask for it, so pages came down uncompressed —
  several times more data over the wire — and a server that sent gzip anyway
  produced an unreadable page. Local `.gz` files were not decompressed
  either.
- The Windows build now looks for a CA trust store under `C:\ssl`. It pointed
  at `/etc/ssl`, a path that cannot exist on Windows, so turning the bundled
  Mozilla CA bundle off with `-ssl.builtin-certificates 0` left the browser
  with nowhere to read certificates from.
