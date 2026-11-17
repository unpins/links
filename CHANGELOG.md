# Changelog

## [Unreleased]

### Added

- Linux: mouse support on the text console (gpm), as in distribution builds.

### Changed

- Windows: HTTPS is verified against the Mozilla roots built into the
  binary's TLS library, the same list Linux and macOS fall back to, rather
  than links' own bundled copy. `SSL_CERT_FILE` and `SSL_CERT_DIR` name your
  own CAs.

### Fixed

- The 2.30-2 notes said the Windows build reads a CA store under `C:\ssl`.
  It never does: any user can create that directory, so it is not trusted.

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
