{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "sddm-astronaut-theme";
  src = pkgs.fetchFromGitHub {
    owner = "totoro-ghost";
    repo = "sddm-astronaut";
    hash = "sha256-j8pJvBml2LWxXNw1e/cSVXV+6w+K1lahv0uK1B9OYn0=";
    rev = "6726b5e951a13d308bf17aa09e91a349d82c997b";
  };
  # Tip: use diff <filea> <fileb> -ur to create patches
  patches = [
    (pkgs.writeText "astronaut-patch" ''
      --- a/metadata.desktop
      +++ b/metadata.desktop
      @@ -9,3 +9,4 @@
       MainScript=Main.qml
       ConfigFile=theme.conf
       Theme-Id=sddm-astronaut
      +QTVersion=6
    '')
  ];
  installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
  '';
}
