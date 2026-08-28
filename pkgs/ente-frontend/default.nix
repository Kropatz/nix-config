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
      rev = "6e19d5e27e769fe48cfa2223c2f5f113fd087389";
    })
  }/website/tracker-site";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-9BWrCWEEbYURjx4N5BZ9lNKde8zruGKepMn/6y7rzLc=";
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
