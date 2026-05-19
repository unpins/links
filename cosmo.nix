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
  cosmoPkgs = unpins-lib.lib.cosmoStaticCross pkgs;
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
