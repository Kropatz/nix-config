{ pkgs, ... }: rec {
  kop-hub = pkgs.callPackage ./hub/default.nix { };
  ente-frontend = pkgs.callPackage ./ente-frontend/default.nix { };
  kop-website =
    pkgs.callPackage ./website/default.nix { inherit kop-hub ente-frontend; };
  kop-monitor = pkgs.callPackage ./kop-monitor/default.nix { };
  kop-fileshare = pkgs.callPackage ./kop-fileshare/default.nix { };
  adam-site = pkgs.callPackage ./adam-site/default.nix { };
}
