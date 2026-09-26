{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  npm-lockfile-fix,
  fetchPnpmDeps,
  nodejs,
  pnpm,
  pnpmConfigHook,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ente-website";
  version = "1.1.0";

  src = "${
    (fetchGit {
      url = "ssh://gitea@git.kopatz.dev/oberprofis/ente.git";
      ref = "master";
      rev = "209b40aaa24b3cfe2814807416fa17072ef81c22";
    })
  }/website/tracker-site";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-lD1iCvvQDby+epSTNO+0Qv64H3p+doq/jclx8nR5ij4=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    pnpm run build
    cp -r ./dist/tracker-site/browser/* $out
    runHook postInstall
  '';
})
