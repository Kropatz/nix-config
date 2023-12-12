{ config, pkgs, inputs, ...}:
{
    programs.lf = {
      enable = true;
      previewer.source = pkgs.writeShellScript "pv.sh" ''
        #!/bin/sh
        case "$(${pkgs.file}/bin/file -Lb --mime-type -- "$1")" in
          #image/*|video/*) ${pkgs.chafa}/bin/chafa -f sixel -s "$2x$3" --animate false $1;;
          application/x-tar) tar tf "$1";;
          application/vnd.rar) ${pkgs.p7zip}/bin/7z l "$1";;
          application/x-7z-compressed) ${pkgs.p7zip}/bin/7z l "$1";;
          *) ${pkgs.ctpv}/bin/ctpv "$1";;
        esac
      '';
    };
}
