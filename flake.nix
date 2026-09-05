{
  description = "links as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    unpins-lib.url = "github:unpins/nix-lib";
    unpins-lib.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Linux/macOS: pkgsStatic.links2 with the graphics chain stripped (no
  # X11/framebuffer, no libpng/libjpeg/libtiff/libavif/librsvg/libev).
  # --without-libevent makes links fall back to plain select(), which on
  # cosmocc-Windows is translated to WSAPoll+WaitForMultipleObjects by
  # cosmo libc — the pure-mingw cross was a dead end because winsock2
  # select() only accepts SOCKETs and links muxes sockets+pipes+console
  # handles through one select() call.
  #
  # Windows: routed through Cosmopolitan (`windowsBuild = import ./cosmo.nix
  # …`); the text-only override + apelink lives inline in `./cosmo.nix`.
  outputs = { self, nixpkgs, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      dnsFallback = true; # resolves hostnames; opt into the Android DNS fallback
      # User-facing id is `links` (binary, gh repo, artifact). nixpkgs
      # ships the package as `links2`, so `pkgsAttr` overrides the
      # lookup (used by cosmoStaticCross.${pkgsAttr} on Windows; the
      # native path uses our custom `build` below and bypasses pkgsAttr).
      name = "links";

      # Build via the unpin-llvm engine + emit a bitcode multicall module.
      engine = "unpin-llvm";
      multicall = {
        programs = [{ name = "links"; }];
      };
      pkgsAttr = "links2";
      windowsBuild = import ./cosmo.nix { inherit unpins-lib; };
      # links uses single-dash flags; pair `-version` with a pattern to
      # avoid the exit-0 false-pass on unknown options.
      smoke = [ "-version" ];
      smokePattern = "Links 2\\.";
      build = pkgs:
        let
          p = pkgs.pkgsStatic;
          # brotli and zstd are Content-Encodings links 2.30 supports and the
          # web actually serves; without them in buildInputs its configure
          # just reported `Supported compression: ZLIB BZIP2 LZMA` and links
          # never advertised br/zstd in Accept-Encoding.
          textInputs = [ p.openssl p.zlib p.bzip2 p.xz p.brotli p.zstd ];
        in
        (p.links2.override {
          enableX11 = false;
          enableFB = false;
        }).overrideAttrs (old: {
          buildInputs = textInputs;
          propagatedBuildInputs = textInputs;
          # links2 2.30's hand-written configure only accepts a subset of the
          # GNU dir flags; the current nixpkgs stdenv auto-adds `--docdir`
          # (and friends), which it rejects. Drop the auto output-dir flags —
          # `--prefix` still applies and man installs to $out/share/man.
          setOutputFlags = false;
          # `AC_CHECK_LIB(brotlidec, ...)` links -lbrotlidec alone, which
          # cannot resolve statically: libbrotlidec.a calls into
          # libbrotlicommon.a. The probe failed and brotli was dropped in
          # silence. Seeding LIBS puts brotlicommon after brotlidec in every
          # later link, the final one included. It goes through the
          # environment because this configure reads `LIBS=...` on the
          # command line as a host type and discards it with a warning.
          preConfigure = (old.preConfigure or "") + ''
            export LIBS="-lbrotlicommon $LIBS"
          '';
          configureFlags = (old.configureFlags or [ ]) ++ [
            "--disable-graphics"
            "--without-x"
            "--without-libevent"
            "--enable-utf8"
            "--enable-debuglevel=0"
          ];
        });
    };
}
