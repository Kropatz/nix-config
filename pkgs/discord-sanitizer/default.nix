{
  fetchPnpmDeps,
  lib,
  fetchFromGitHub,
  nodejs,
  pnpm,
  pnpmConfigHook,
  stdenv,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "discord-sanitizer";
  version = "1.0.0";

  src = fetchGit {
    url = "gitea@git.kopatz.dev:kopatz/url-replacer-bot.git";
    ref = "master";
    rev = "4b5e4fdc73a99e24e93eedd1d3ae020736986aaf";
  };

  nativeBuildInputs = [
    nodejs # in case scripts are run outside of a pnpm call
    pnpmConfigHook
    pnpm # At least required by pnpmConfigHook, if not other (custom) phases
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    cp -r . $out/lib/
    makeWrapper ${nodejs}/bin/node $out/bin/discord-sanitizer \
      --add-flags $out/lib/index.js
    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 1; # Dropped from 3 due to chmod error when no -exec exists
    hash = "sha256-rfXMiQp3HfZjaHjFhGGBEMWLqhgFZBSe0x/10lLHCLc=";
  };
})
