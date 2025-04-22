{ lib
, rustPlatform
, stdenv
, fetchFromGitHub
, blueprint-compiler
, pkg-config
, wrapGAppsHook4
, gdk-pixbuf
, gtk4
, libdrm
, vulkan-loader
, coreutils
, nix-update-script
, hwdata
, fuse
}:

rustPlatform.buildRustPackage rec {
  pname = "lact";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "ilya-zlobintsev";
    repo = "LACT";
    rev = "v${version}";
    hash = "sha256-R8VEAk+CzJCxPzJohsbL/XXH1GMzGI2W92sVJ2evqXs=";
    #rev = "e472dec45682f96a272b77d368791121e10ba7da";
    #hash = "sha256-d081f49ojJzz0N28lIu3NZ8SSvSuoz2HfjQl5Zu8PpU=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-SH7jmXDvGYO9S5ogYEYB8dYCF3iz9GWDYGcZUaKpWDQ=";

  nativeBuildInputs =
    [ blueprint-compiler pkg-config wrapGAppsHook4 rustPlatform.bindgenHook ];

  buildInputs = [ gdk-pixbuf gtk4 libdrm vulkan-loader hwdata fuse ];

  # we do this here so that the binary is usable during integration tests
  RUSTFLAGS = lib.optionalString stdenv.targetPlatform.isElf
    (lib.concatStringsSep " " [
      "-C link-arg=-Wl,-rpath,${lib.makeLibraryPath [ vulkan-loader libdrm ]}"
      "-C link-arg=-Wl,--add-needed,${vulkan-loader}/lib/libvulkan.so"
      "-C link-arg=-Wl,--add-needed,${libdrm}/lib/libdrm.so"
    ]);

  checkFlags = [
    # tries and fails to initialize gtk
    "--skip=app::pages::thermals_page::fan_curve_frame::tests::set_get_curve"
    "--skip=tests::snapshot_everything"
  ];

  postPatch = ''
    substituteInPlace lact-daemon/src/server/system.rs \
      --replace-fail 'Command::new("uname")' 'Command::new("${coreutils}/bin/uname")'

    substituteInPlace res/lactd.service \
      --replace-fail ExecStart={lact,$out/bin/lact}

    substituteInPlace res/io.github.ilya_zlobintsev.LACT.desktop \
      --replace-fail Exec={lact,$out/bin/lact}

    # read() looks for the database in /usr/share so we use read_from_file() instead
    substituteInPlace lact-daemon/src/server/handler.rs \
      --replace-fail 'Database::read()' 'Database::read_from_file("${hwdata}/share/hwdata/pci.ids")'
  '';

  postInstall = ''
    install -Dm444 res/lactd.service -t $out/lib/systemd/system
    install -Dm444 res/io.github.ilya_zlobintsev.LACT.desktop -t $out/share/applications
    install -Dm444 res/io.github.ilya_zlobintsev.LACT.png -t $out/share/pixmaps
  '';

  postFixup = lib.optionalString stdenv.targetPlatform.isElf ''
    patchelf $out/bin/.lact-wrapped \
    --add-needed libvulkan.so \
    --add-needed libdrm.so \
    --add-rpath ${lib.makeLibraryPath [ vulkan-loader libdrm ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Linux GPU Configuration Tool for AMD and NVIDIA";
    homepage = "https://github.com/ilya-zlobintsev/LACT";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ figsoda atemu ];
    platforms = lib.platforms.linux;
    mainProgram = "lact";
  };
}
