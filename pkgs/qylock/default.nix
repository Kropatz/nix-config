{
  pkgs,
  selectedTheme ? "nier-automata",
}:
let
  basePath = "$out/share/sddm/themes/${selectedTheme}";
  quickshellPath = "$out/lib/quickshell-lockscreen";
  lock = pkgs.writeShellScriptBin "qylock-lock" ''
    export QML_IMPORT_PATH="${theme}/lib/quickshell-lockscreen/imports:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml:${pkgs.kdePackages.qt5compat}/lib/qt-6/qml''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
    export QML2_IMPORT_PATH="$QML_IMPORT_PATH"
    export QML_XHR_ALLOW_FILE_READ=1
    # export QS_FINGERPRINT=1
    # export QS_PAM_SERVICE=qylock 
    cd ${theme}/lib/quickshell-lockscreen
    exec ${pkgs.quickshell}/bin/quickshell -p lock_shell.qml "$@"
  '';
  theme = pkgs.stdenv.mkDerivation {
    name = "qylock-theme-${selectedTheme}";
    src = pkgs.fetchFromGitHub {
      owner = "Darkkal44";
      repo = "qylock";
      hash = "sha256-u1+0dkL4gYyIQP/Ap2cGyf6WhQbUNHxDQDkxT/gbZ1Q=";
      rev = "bece4d25a9dcd043a072847c8ed92dca3800616e";
    };
    # patches = [
    #   ./fprint.patch
    # ];
    installPhase = ''
      mkdir -p ${basePath}
      cp -r $src/themes/${selectedTheme}/* ${basePath}

      mkdir -p ${quickshellPath}
      cp $src/quickshell-lockscreen/lock_shell.qml ${quickshellPath}/lock_shell.qml
      cp -r --no-preserve=mode,ownership \
        $src/quickshell-lockscreen/shim ${quickshellPath}/shim
      cp -r --no-preserve=mode,ownership \
        $src/quickshell-lockscreen/imports ${quickshellPath}/imports
      ln -s $out/share/sddm/themes $out/lib/quickshell-lockscreen/themes_link
    '';
  };
  package = pkgs.stdenv.mkDerivation {
    name = "qylock";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${lock}/bin/qylock-lock $out/bin/qylock-lock

      mkdir -p $out/share/sddm/themes
      ln -s ${theme}/share/sddm/themes/${selectedTheme} $out/share/sddm/themes/${selectedTheme}
    '';
  };
in
package
# Qt5Compat.GraphicalEffects is not installed

# export QML_IMPORT_PATH="${qylockShell}/imports:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml:${pkgs.kdePackages.qt5compat}/lib/qt-6/qml''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
# export QML2_IMPORT_PATH="$QML_IMPORT_PATH"
# export QML_XHR_ALLOW_FILE_READ=1
# export QS_THEME="${theme}"
