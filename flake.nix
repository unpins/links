{
  description = "Standalone build of links";

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
      # User-facing id is `links` (binary, gh repo, artifact). nixpkgs
      # ships the package as `links2`, so `pkgsAttr` overrides the
      # lookup (used by cosmoStaticCross.${pkgsAttr} on Windows; the
      # native path uses our custom `build` below and bypasses pkgsAttr).
      name = "links";
      pkgsAttr = "links2";
      windowsBuild = import ./cosmo.nix { inherit unpins-lib; };
      # links uses single-dash flags; pair `-version` with a pattern to
      # avoid the exit-0 false-pass on unknown options.
      smoke = [ "-version" ];
      smokePattern = "Links 2\\.";
      build = pkgs:
        let
          p = pkgs.pkgsStatic;
          textInputs = [ p.openssl p.zlib p.bzip2 p.xz ];
        in
        (p.links2.override {
          enableX11 = false;
          enableFB = false;
        }).overrideAttrs (old: {
          buildInputs = textInputs;
          propagatedBuildInputs = textInputs;
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
