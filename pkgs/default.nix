{ pkgs, ... }:
rec {
  ente-frontend = pkgs.callPackage ./ente-frontend/default.nix { };
  ente-backend = pkgs.callPackage ./ente-backend/default.nix { };
  kop-fhcalendar = pkgs.callPackage ./kop-fhcalendar/default.nix { };
  kop-fileshare = pkgs.callPackage ./kop-fileshare/default.nix { };
  kop-pvlog = pkgs.callPackage ./kop-pvlog/default.nix { };
  kop-hub = pkgs.callPackage ./hub/default.nix { };
  kop-monitor = pkgs.callPackage ./kop-monitor/default.nix { };
  kop-newproject = pkgs.callPackage ./kop-newproject/default.nix { };
  kop-website = pkgs.callPackage ./website/default.nix { inherit kop-hub ente-frontend; };
  kop-audio = pkgs.callPackage ./kop-audio/default.nix { };
  kop-llama-systray = pkgs.callPackage ./kop-llama-systray/default.nix { };
  scheibnkleister-presence = pkgs.callPackage ./scheibnkleister-presence/default.nix { };
  custom-sddm-astronaut = pkgs.callPackage ./sddm-astronaut/default.nix { };
  mangal-patched = pkgs.callPackage ./mangal/default.nix { };
  csharp-ls-8 = pkgs.callPackage ./csharp-lsp/default.nix { };
  gpu-screen-recorder-ui = pkgs.callPackage ./gpu-screen-recorder-ui/default.nix { inherit gpu-screen-recorder-notification; };
  gpu-screen-recorder-notification =
    pkgs.callPackage ./gpu-screen-recorder-notification/default.nix
      { };
  kavita-old = pkgs.callPackage ./kavita-old/default.nix { };
  hollow-grub = pkgs.callPackage ./hollow-grub/default.nix { };
  peframe = pkgs.callPackage ./peframe/default.nix {
    python3Packages = pkgs.python3Packages;
    inherit virustotal-api;
  };
  virustotal-api = pkgs.callPackage ./virustotal-api/default.nix {
    python3Packages = pkgs.python3Packages;
  };
  answer = pkgs.callPackage ./answer/default.nix { };
  internxt-cli = pkgs.callPackage ./internxt-cli/default.nix { };
  discord-sanitizer = pkgs.callPackage ./discord-sanitizer/default.nix { };
  qylock = pkgs.callPackage ./qylock/default.nix { };
  crystaldisk-linux = pkgs.callPackage ./crystaldisk-linux/default.nix { };
}
