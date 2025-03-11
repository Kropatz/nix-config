{ pkgs, ... }: rec {
  adam-site = pkgs.callPackage ./adam-site/default.nix { };
  ente-frontend = pkgs.callPackage ./ente-frontend/default.nix { };
  kop-fhcalendar = pkgs.callPackage ./kop-fhcalendar/default.nix { };
  kop-fileshare = pkgs.callPackage ./kop-fileshare/default.nix { };
  kop-hub = pkgs.callPackage ./hub/default.nix { };
  kop-monitor = pkgs.callPackage ./kop-monitor/default.nix { };
  kop-newproject = pkgs.callPackage ./kop-newproject/default.nix { };
  kop-website =
    pkgs.callPackage ./website/default.nix { inherit kop-hub ente-frontend; };
  sddm-astronaut = pkgs.callPackage ./sddm-astronaut/default.nix { };
  mangal-patched = pkgs.callPackage ./mangal/default.nix { };
  electron_27 = pkgs.callPackage ./electron27/default.nix { };
  logseq = pkgs.callPackage ./logseq/default.nix { inherit electron_27; };
  rdna4-lact = pkgs.callPackage ./lact/default.nix { };
}
