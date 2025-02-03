{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  name = "mangal";
  pname = "mangal";

  src = fetchFromGitHub {
    owner = "Kropatz";
    repo = pname;
    rev = "ed061400fbadb0ecceb4f9ae0a39da42475b709d";
    hash = "sha256-778jdPJC8wzrwawbuTPbS5vCOAR76G+1WvbMpQ7jpNw=";
  };

  vendorHash = "sha256-FOi36EmbggxkJ1/wtBO9Vrr716z3dwDevSokFKWwGzY=";

  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # Mangal creates a config file in the folder ~/.config/mangal and fails if not possible
    export HOME=$(mktemp -d)
    installShellCompletion --cmd mangal \
      --bash <($out/bin/mangal completion bash) \
      --zsh <($out/bin/mangal completion zsh) \
      --fish <($out/bin/mangal completion fish)
  '';

  doCheck = false; # test fail because of sandbox

  meta = with lib; {
    description = "CLI app written in Go which scrapes, downloads and packs manga into different formats";
    homepage = "https://github.com/metafates/mangal";
    license = licenses.mit;
    maintainers = [ maintainers.bertof ];
    mainProgram = "mangal";
  };
}
