# links2 via cosmoStaticCross for Windows-x86_64.
#
# nixpkgs' links2 defaults to graphics mode and pulls
# libpng/libjpeg/libtiff/libavif/librsvg/libev/gpm. We ship text-only,
# so drop the graphics chain via enableX11/enableFB=false plus a full
# buildInputs override (pkgsStatic auto-promotes buildInputs into
# propagatedBuildInputs, so overriding only buildInputs leaves the
# graphics libs in the closure — strip propagated too).
#
# --without-libevent makes links use plain select(); cosmo libc
# translates select() to WSAPoll+WaitForMultipleObjects under the hood
# so the existing event loop "just works" on Windows (mingw select()
# only accepts SOCKET handles, which is why the pure-mingw cross at
# playground/links was a dead end).
#
# Patch default.c so the bundled Mozilla CA bundle (certs.inc) is on
# by default — upstream only enables this on DOS/OPENVMS, but our
# Windows binary has no system CA store path baked in (OPENSSLDIR
# resolves to /build/cosmos/etc/ssl which doesn't exist at runtime)
# and asking users for `-ssl.builtin-certificates 1` every invocation
# would be a footgun.
#
# ELF → PE32+ rename to `links.exe` happens automatically via the
# cosmo cross stdenv's apelink setup hook.
{ unpins-lib }:
pkgs:
let
  # OPENSSLDIR/ENGINESDIR/MODULESDIR default to openssl's own $out, so the .exe
  # carried a live reference to `openssl-…-cosmo-gnu-3.6.2-etc` -- and unlike
  # the rsync case this one MATTERS at run time: links is a web browser, and
  # that directory is where libcrypto looks for the CA trust store. Pointed at
  # a store path it finds nothing, so HTTPS verification has nowhere to read
  # certificates from. The cosmo scope has no set-wide retarget (the engine's
  # native scope has one in native-overlay/openssl.nix), so each consumer does
  # it here.
  #
  # The value is the *Windows* trust dir, not the Linux one: this build is
  # published only as the windows-x86_64 artifact, and `/etc/ssl` cannot exist
  # there — a user turning the bundled bundle off (`-ssl.builtin-certificates
  # 0`) would have nowhere to put a CA file. `/c/ssl` is cosmo's spelling of
  # `C:\ssl` (cosmocc README: "C:\bin\sh … in Cosmo-speak is /c/bin/sh"), which
  # is exactly where the mingw consumers point (openssl, opus-tools, rtmpdump,
  # php, python all use C:/ssl).
  cosmoPkgs = (unpins-lib.lib.cosmoStaticCross pkgs).extend (final: prev: {
    openssl = prev.openssl.overrideAttrs (unpins-lib.lib.retargetOpenssl "/c/ssl");
  });
in
(cosmoPkgs.links2.override {
  enableX11 = false;
  enableFB = false;
}).overrideAttrs (oa: {
    buildInputs = with cosmoPkgs; [ openssl zlib bzip2 xz ];
    propagatedBuildInputs = with cosmoPkgs; [ openssl zlib bzip2 xz ];
    configureFlags = (oa.configureFlags or [ ]) ++ [
      "--disable-graphics"
      "--without-x"
      "--without-libevent"
      "--without-brotli"
      "--without-zstd"
      "--enable-utf8"
      "--enable-debuglevel=0"
    ];
    postPatch = (oa.postPatch or "") + ''
      substituteInPlace default.c \
        --replace-fail \
          '#if defined(DOS) || defined(OPENVMS)' \
          '#if defined(DOS) || defined(OPENVMS) || defined(__COSMOPOLITAN__)'
    '';
  })
