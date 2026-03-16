{
  fetchPnpmDeps,
  lib,
  fetchFromGitHub,
  nodejs,
  pnpm,
  pnpmConfigHook,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adam-site";
  version = "2.0.0";

  src = fetchGit {
    url = "gitea@git.kopatz.dev:oberprofis/adams.git";
    ref = "main";
    rev = "835bd7b200ad949871d915ee57a9ed785f1c75ef";
  };

  nativeBuildInputs = [
    nodejs # in case scripts are run outside of a pnpm call
    pnpmConfigHook
    pnpm # At least required by pnpmConfigHook, if not other (custom) phases
  ];

  buildPhase = ''
    pnpm run build
  '';

  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-XSfxEmZ9bkHmSsiLXF7qFQ6BI+JdCzdU+BNSvAjzJkU=";
  };
})
