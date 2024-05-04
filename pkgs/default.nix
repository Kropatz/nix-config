{pkgs, ...}: rec {
  tetrio = pkgs.callPackage ./tetrio-desktop/package.nix { };
  hub = pkgs.callPackage ./hub/default.nix { };
  ente-frontend = pkgs.callPackage ./ente-frontend/default.nix { };
  website = pkgs.callPackage ./website/default.nix { inherit hub ente-frontend; };
}
