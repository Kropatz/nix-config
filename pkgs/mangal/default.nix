{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, installShellFiles
, libgbm
, makeWrapper
,
}:
buildGoModule rec {
  name = "mangal";
  pname = "mangal";

  src = fetchFromGitHub {
    owner = "Kropatz";
    repo = pname;
    rev = "ebbbc83ce87f124cc819ef440e40f1c93a5f2ecd";
    hash = "sha256-++fJhHbEKNg3XaCPrYzUmMpF44IM3C1W69ZsTTSqX2g=";
  };

  vendorHash = "sha256-FOi36EmbggxkJ1/wtBO9Vrr716z3dwDevSokFKWwGzY=";

  ldflags = [
    "-s"
    "-w"
  ];

  buildInputs = [ libgbm ];
  runtimeDeps = [ libgbm ];
  nativeBuildInputs = [ installShellFiles makeWrapper ];

  preFixup = ''
    wrapProgram $out/bin/mangal --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libgbm ]}
  '';

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
