# links

[Twibright Links](https://links.twibright.com/), a text-mode web browser with HTTPS, HTTP/1.1 and compressed transfers. A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/links/actions/workflows/links.yml/badge.svg)](https://github.com/unpins/links/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install links`.

Text-only build: the graphics mode (X11, framebuffer, image decoding) and mouse
support are left out, so this is the browser as it runs in a terminal.

**Certificates.** On Linux and macOS, links verifies HTTPS against the system's
CA store, the same as your distribution's build. On a machine that has none — a
minimal container, for instance — pass `-ssl.builtin-certificates 1` to use the
Mozilla root list that ships inside the binary instead. The Windows build uses
that built-in list by default, since Windows keeps no CA store where links can
read it.

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
