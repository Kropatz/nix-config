{ pkgs, ... }: rec {
  tetrio = pkgs.callPackage ./tetrio-desktop/package.nix { };
  kop-hub = pkgs.callPackage ./hub/default.nix { };
  ente-frontend = pkgs.callPackage ./ente-frontend/default.nix { };
  kop-website =
    pkgs.callPackage ./website/default.nix { inherit kop-hub ente-frontend; };
  kop-monitor = pkgs.callPackage ./kop-monitor/default.nix { };
}
