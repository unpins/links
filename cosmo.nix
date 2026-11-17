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
# translates select() to WSAPoll+WaitForMultipleObjects, so the event
# loop works on Windows (mingw select() only accepts SOCKET handles).
#
# ELF → PE32+ rename to `links.exe` happens automatically via the
# cosmo cross stdenv's apelink setup hook.
{ unpins-lib }:
pkgs:
let
  # OPENSSLDIR/ENGINESDIR/MODULESDIR default to openssl's own $out, a store
  # path baked into the .exe. The cosmo scope has no set-wide retarget, so do
  # it here; `/c/ssl` (cosmo for `C:\ssl`) matches the mingw consumers. It only
  # moves that string out of the store: retargetOpenssl's CA fallback never
  # reads OPENSSLDIR on Windows, and HTTPS verifies against its embedded
  # Mozilla roots (or SSL_CERT_FILE / SSL_CERT_DIR).
  cosmoPkgs = (unpins-lib.lib.cosmoStaticCross pkgs).extend (final: prev: {
    openssl = prev.openssl.overrideAttrs (unpins-lib.lib.retargetOpenssl "/c/ssl");
  });
in
(cosmoPkgs.links2.override {
  enableX11 = false;
  enableFB = false;
}).overrideAttrs (oa: {
    buildInputs = with cosmoPkgs; [ openssl zlib bzip2 xz brotli zstd ];
    propagatedBuildInputs = with cosmoPkgs; [ openssl zlib bzip2 xz brotli zstd ];
    configureFlags = (oa.configureFlags or [ ]) ++ [
      "--disable-graphics"
      "--without-libevent"
    ];
    preConfigure = (oa.preConfigure or "") + ''
      export LIBS="-lbrotlicommon $LIBS"
    '';
  })
