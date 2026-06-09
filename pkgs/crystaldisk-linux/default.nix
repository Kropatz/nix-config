{
  lib,
  stdenvNoCC,
  python3,
  smartmontools,
  qt6,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:

let
  python = python3.withPackages (ps: [ ps.pyqt6 ]);
in
stdenvNoCC.mkDerivation {
  pname = "crystaldiskinfo-clone";
  version = "0.1.0";
  src = fetchGit {
    url = "gitea@git.kopatz.dev:kopatz/crystaldiskinfo-linux.git";
    ref = "master";
    rev = "7d4707171ac84a4d856fb77d935dcc1c507e0d79";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    qt6.wrapQtAppsHook
  ];
  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "crystaldiskinfo-clone";
      desktopName = "CrystalDiskInfo Clone";
      genericName = "Drive Health Monitor";
      comment = "S.M.A.R.T. drive health viewer";
      exec = "crystaldiskinfo-clone";
      icon = "drive-harddisk";
      terminal = false;
      categories = [
        "System"
        "Monitor"
        "Qt"
      ];
      keywords = [
        "SMART"
        "disk"
        "drive"
        "health"
        "temperature"
        "nvme"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/crystaldiskinfo-clone
    cp -r main.py smart.py fixtures $out/share/crystaldiskinfo-clone/

    # wrapQtAppsHook re-wraps this with the Qt platform plugin environment
    makeWrapper ${python.interpreter} $out/bin/crystaldiskinfo-clone \
      --add-flags $out/share/crystaldiskinfo-clone/main.py \
      --prefix PATH : ${lib.makeBinPath [ smartmontools ]}

    runHook postInstall
  '';

  meta = {
    description = "CrystalDiskInfo-style S.M.A.R.T. drive health viewer";
    mainProgram = "crystaldiskinfo-clone";
    platforms = lib.platforms.linux;
  };
}
