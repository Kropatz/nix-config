{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.wayvnc;
in
{

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (wayvnc.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "any1";
          repo = "wayvnc";
          rev = "f45ab1dd07884e02ba8d6ff32c440705c5f62d22";
          sha256 = "sha256-m6zt7KTDCTHFvECIXaWOwCXvoQVB43AxTtM/LXnz+xE=";
        };
        buildInputs = with pkgs; [
          (aml.overrideAttrs {
            pname = "aml1";
            src = pkgs.fetchFromGitHub {
              owner = "any1";
              repo = "aml";
              rev = "v1.0.0";
              sha256 = "0cp0hmlfrsvmdrdhcr2b4msvhv80zx43bxqq995vlrk1ibljcj6p";
            };
          })
          (neatvnc.overrideAttrs {
            pname = "neatvnc1";
            src = pkgs.fetchFromGitHub {
              owner = "any1";
              repo = "neatvnc";
              rev = "408aef247acabb9b5db1380ca595542ca237c0c2";
              sha256 = "04brfcgkysk7j5vlgl91za4qj2sr9r6mn5maj8bndw6hzkmj4nhf";
            };
            nativeBuildInputs = [
              meson
              ninja
              pkg-config
              openssl
            ];
            buildInputs = [
              (aml.overrideAttrs {
                pname = "aml1";
                src = pkgs.fetchFromGitHub {
                  owner = "any1";
                  repo = "aml";
                  rev = "v1.0.0";
                  sha256 = "0cp0hmlfrsvmdrdhcr2b4msvhv80zx43bxqq995vlrk1ibljcj6p";
                };
              })
              ffmpeg
              gnutls
              libjpeg_turbo
              libgbm
              pixman
              zlib
              openssl
            ];
          })
          jansson
          libxkbcommon
          libgbm
          pam
          pixman
          wayland
        ];
      })
    ];
    networking.firewall.allowedTCPPorts = [ 5900 ];
  };
}
