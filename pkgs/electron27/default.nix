{ lib, stdenv, libXScrnSaver, makeWrapper, fetchurl, wrapGAppsHook3, glib, gtk3
, unzip, at-spi2-atk, libdrm, libgbm, libxkbcommon, libxshmfence, libGL
, vulkan-loader, alsa-lib, cairo, cups, dbus, expat, gdk-pixbuf, nss, nspr, xorg
, pango, systemd, pciutils, }:

let
  version = "27.3.11";
  hashes = {
    "aarch64-darwin" =
      "a687b199fcb9890f43af90ac8a4d19dc7b15522394de89e42abd5f5c6b735804";
    "aarch64-linux" =
      "ddbfcd5e04450178ca4e3113f776893454822af6757761adc792692f7978e0df";
    "armv7l-linux" =
      "012127a3edf79e0e4623a08e853286e1cba512438a0414b1ab19b75d929c1cf2";
    "headers" = "0vrjdvqllfyz09sw2y078mds1di219hnmska8bw8ni7j35wxr2br";
    "x86_64-darwin" =
      "357e70a1c8848d4ac7655346bec98dd18a7c0cee82452a7edf76142017779049";
    "x86_64-linux" =
      "e3a6f55e54e7a623bba1a15016541248408eef5a19ab82a59d19c807aab14563";

  };
  pname = "electron";

  meta = with lib; {
    description = "Cross platform desktop application shell";
    homepage = "https://github.com/electron/electron";
    license = licenses.mit;
    mainProgram = "electron";
    maintainers = with maintainers; [ yayayayaka teutat3s ];
    platforms =
      [ "x86_64-darwin" "x86_64-linux" "armv7l-linux" "aarch64-linux" ]
      ++ optionals (versionAtLeast version "11.0.0") [ "aarch64-darwin" ]
      ++ optionals (versionOlder version "19.0.0") [ "i686-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    # https://www.electronjs.org/docs/latest/tutorial/electron-timelines
    knownVulnerabilities = optional (versionOlder version "32.0.0")
      "Electron version ${version} is EOL";
  };

  fetcher = vers: tag: hash:
    fetchurl {
      url =
        "https://github.com/electron/electron/releases/download/v${vers}/electron-v${vers}-${tag}.zip";
      sha256 = hash;
    };

  headersFetcher = vers: hash:
    fetchurl {
      url =
        "https://artifacts.electronjs.org/headers/dist/v${vers}/node-v${vers}-headers.tar.gz";
      sha256 = hash;
    };

  tags = {
    x86_64-linux = "linux-x64";
    armv7l-linux = "linux-armv7l";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x64";
  } // lib.optionalAttrs (lib.versionAtLeast version "11.0.0") {
    aarch64-darwin = "darwin-arm64";
  } // lib.optionalAttrs (lib.versionOlder version "19.0.0") {
    i686-linux = "linux-ia32";
  };

  get = as: platform:
    as.${platform.system} or (throw "Unsupported system: ${platform.system}");

  common = platform: {
    inherit pname version meta;
    src = fetcher version (get tags platform) (get hashes platform);
    passthru.headers = headersFetcher version hashes.headers;
  };

  electronLibPath = lib.makeLibraryPath ([
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    nss
    nspr
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxkbfile
    pango
    pciutils
    stdenv.cc.cc
    systemd
  ] ++ lib.optionals (lib.versionAtLeast version "9.0.0") [ libdrm libgbm ]
    ++ lib.optionals (lib.versionOlder version "10.0.0") [ libXScrnSaver ]
    ++ lib.optionals (lib.versionAtLeast version "11.0.0") [ libxkbcommon ]
    ++ lib.optionals (lib.versionAtLeast version "12.0.0") [ libxshmfence ]
    ++ lib.optionals (lib.versionAtLeast version "17.0.0") [
      libGL
      vulkan-loader
    ]);

  linux = finalAttrs: {
    buildInputs = [ glib gtk3 ];

    nativeBuildInputs = [ unzip makeWrapper wrapGAppsHook3 ];

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/libexec/electron $out/bin
      unzip -d $out/libexec/electron $src
      ln -s $out/libexec/electron/electron $out/bin
      chmod u-x $out/libexec/electron/*.so*
    '';

    postFixup = ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${electronLibPath}:$out/libexec/electron" \
        $out/libexec/electron/.electron-wrapped \
        ${
          lib.optionalString (lib.versionAtLeast version "15.0.0")
          "$out/libexec/electron/.chrome_crashpad_handler-wrapped"
        }

      # patch libANGLE
      patchelf \
        --set-rpath "${lib.makeLibraryPath [ libGL pciutils vulkan-loader ]}" \
        $out/libexec/electron/lib*GL*

      # replace bundled vulkan-loader
      rm "$out/libexec/electron/libvulkan.so.1"
      ln -s -t "$out/libexec/electron" "${
        lib.getLib vulkan-loader
      }/lib/libvulkan.so.1"
    '';

    passthru.dist = finalAttrs.finalPackage + "/libexec/electron";
  };

  darwin = finalAttrs: {
    nativeBuildInputs = [ makeWrapper unzip ];

    buildCommand = ''
      mkdir -p $out/Applications
      unzip $src
      mv Electron.app $out/Applications
      mkdir -p $out/bin
      makeWrapper $out/Applications/Electron.app/Contents/MacOS/Electron $out/bin/electron
    '';

    passthru.dist = finalAttrs.finalPackage + "/Applications";
  };
in stdenv.mkDerivation (finalAttrs:
  lib.recursiveUpdate (common stdenv.hostPlatform)
  ((if stdenv.hostPlatform.isDarwin then darwin else linux) finalAttrs))
