# links

[Twibright Links](https://links.twibright.com/), a text-mode web browser with HTTPS, HTTP/1.1 and compressed transfers. A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/links/actions/workflows/links.yml/badge.svg)](https://github.com/unpins/links/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install links`.

Text-only build: the graphics mode (X11, framebuffer, image decoding) is left
out, so this is the browser as it runs in a terminal.

**Certificates.** On Linux and macOS, links verifies HTTPS against the system's
CA store, the same as your distribution's build. On a machine that has none — a
minimal container, for instance — it uses the Mozilla root list built into the
binary instead. The Windows build always uses that built-in list. To trust your
own CAs, point `SSL_CERT_FILE` at a PEM bundle or `SSL_CERT_DIR` at a
directory of certificates.

## Usage

Run the `links` program with [unpin](https://github.com/unpins/unpin):

```bash
unpin links https://example.com
```

To install it onto your PATH:

```bash
unpin install links
```

## Man pages

`links.1` is embedded in the binary — read with `unpin man links`.

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

## Manual download

The [Releases](https://github.com/unpins/links/releases) page has standalone binaries for manual download.

## Build notes

- **Windows:** cosmo, not mingw, because links waits on sockets, pipes and the
  console in one `select()` call, and mingw's `select()` accepts only sockets.
- **Not included:** the graphics mode (`links -g`: X11, framebuffer and the
  image decoders; this is the terminal browser); lzip decompression (off in
  nixpkgs).
- **Tests:** links ships no test suite.
