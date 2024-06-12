{ osConfig, pkgs, lib, inputs, ... }:
let cfg = osConfig.custom.services.opensnitch;
in { config = lib.mkIf cfg.enable { services.opensnitch-ui.enable = true; }; }
