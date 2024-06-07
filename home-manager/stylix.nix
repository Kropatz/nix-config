{ osConfig, pkgs, config, lib, ... }:
let cfg = osConfig.custom.graphical.stylix;
in { config = lib.mkIf cfg.enable { stylix.enable = true; }; }
