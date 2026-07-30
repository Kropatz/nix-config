{
  buildGoModule,
  stdenv,
  pkgs,
  lib,
  ...
}:
buildGoModule rec {
  pname = "kop-llama-systray";
  version = "0.0.1";

  src = fetchGit {
    url = "ssh://gitea@git.kopatz.dev/kopatz/llama-systray.git";
    ref = "master";
    rev = "3c2baf722da089b2b7400349518a6badb93c84a3";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    makeWrapper
  ];
  buildInputs = with pkgs; [
    gtk3
    libayatana-appindicator
    llama-cpp-vulkan
  ];
  vendorHash = "sha256-O6IWRFmLFxtI5uSTPPtyYdoAIrLltPbNBRkRZZTE0SE=";

  postInstall = ''
    mv $out/bin/llama-systray $out/bin/kop-llama-systray
    wrapProgram $out/bin/kop-llama-systray \
      --prefix PATH : ${lib.makeBinPath [ pkgs.llama-cpp-vulkan ]}
  '';

  meta = {
    description = "Systray application to easily start/stop llama server";
    license = lib.licenses.gpl3;
  };
}
