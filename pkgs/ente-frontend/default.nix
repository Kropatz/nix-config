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
      rev = "96f05d6e65b0013d93d1177994022991fdd743de";
    })
  }/website/tracker-site";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-PfGTocc8sV0F1gpa9yr7nJFBm23gHy6OCYD5o5XygYc=";
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
