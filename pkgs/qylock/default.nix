{
  pkgs,
  selectedTheme ? "nier-automata",
}:
let
  basePath = "$out/share/sddm/themes/${selectedTheme}";
in
pkgs.stdenv.mkDerivation {
  name = "qylock";
  src = pkgs.fetchFromGitHub {
    owner = "Darkkal44";
    repo = "qylock";
    hash = "sha256-u1+0dkL4gYyIQP/Ap2cGyf6WhQbUNHxDQDkxT/gbZ1Q=";
    rev = "bece4d25a9dcd043a072847c8ed92dca3800616e";
  };
  installPhase = ''
    mkdir -p ${basePath}
    cp -r $src/themes/${selectedTheme}/* ${basePath}
  '';
}
# Qt5Compat.GraphicalEffects is not installed
