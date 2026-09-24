{
  lib,
  stdenv,
  stdenvNoCC,
  bun,
  writableTmpDirAsHomeHook,
  makeBinaryWrapper,
  typescript,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ente-backend";
  version = "1.0.0";

  src = "${
    (fetchGit {
      url = "ssh://gitea@git.kopatz.dev/oberprofis/ente.git";
      ref = "master";
      rev = "209b40aaa24b3cfe2814807416fa17072ef81c22";
    })
  }/new-bot";

  nativeBuildInputs = [
    makeBinaryWrapper
    typescript
  ];

  configurePhase = ''
    runHook preConfigure

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/ente
    cp -R ${nodeModules}/. $out/share/ente
    cp -R src/ $out/share/ente
    cp -R tsconfig.json $out/share/ente
    cp -R package.json $out/share/ente
    cp -R bun.lockb $out/share/ente

    mkdir -p $out/bin
    makeBinaryWrapper ${bun}/bin/bun $out/bin/ente \
      --add-flags "run --prefer-offline --no-install $out/share/ente/src/bot/application.ts" \
      --set NODE_ENV production \

    runHook postInstall
  '';

  # ======= NODE MODULES =======
  nodeModules = stdenvNoCC.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version src;

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      bun install --frozen-lockfile --allow-scripts --no-progress
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r node_modules $out/node_modules
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash =
      {
        x86_64-linux = "sha256-m2xKKaaFMh2KguF4HmbsjR65w5vnfua0VTCMmcPC5nk=";
        aarch64-linux = "";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system ${stdenv.hostPlatform.system}");
  };
}
