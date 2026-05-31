# links

Standalone build of [Twibright Links](https://links.twibright.com/), a text-mode web browser with HTTPS, gzip and HTTP/1.1 support.

[![CI](https://github.com/unpins/links/actions/workflows/links.yml/badge.svg)](https://github.com/unpins/links/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

Text-only build: graphics (X11/framebuffer, libpng/libjpeg/libtiff/libavif/librsvg) and gpm/libev are stripped from the closure. HTTPS works out of the box via a bundled Mozilla CA bundle (no host `/etc/ssl/certs` required).

Linux/macOS use `pkgsStatic`. Windows is built via [Cosmopolitan](https://justine.lol/cosmopolitan/) (cosmocc cross-toolchain inside Nix) because mingw's `select()` only accepts SOCKETs, while links muxes sockets+pipes+console handles through a single `select()` call — pure-mingw cross compiles cleanly but dies at runtime with `WSAENOTSOCK`. Cosmocc's libc translates `select()` to `WSAPoll` + `WaitForMultipleObjects`, so the existing event loop works unchanged.

## Installation

Install with [unpin](https://github.com/unpins/unpin):

```bash
unpin links
```

Or run without installing:

```bash
unpin run links
```

## Build locally

```bash
nix build github:unpins/links
./result/bin/links -dump https://example.com
```

Or run directly:

```bash
nix run github:unpins/links
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Man pages

`links.1` is embedded in the binary — read with `unpin man links`.

## Manual download

The [Releases](https://github.com/unpins/links/releases) page has standalone binaries for manual download.
