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
      url = "gitea@git.kopatz.dev:oberprofis/ente.git";
      ref = "master";
      rev = "e25759557425b18a677bc23a9dad6a7f96e9e313";
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
        x86_64-linux = "sha256-pX1oh2Q4bXELabbH8N8KtLjZYb9iRVKocr1Fk3Nnbpw=";
        aarch64-linux = "";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system ${stdenv.hostPlatform.system}");
  };
}
