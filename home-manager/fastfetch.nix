{ lib, pkgs, ... }: {
  programs.fastfetch = {
    enable = true;

    settings = {
      #logo = { source = ../test.sixel; type = "raw"; width = 40; height = 40; };
      display = { separator = ""; };

      # https://www.nerdfonts.com/cheat-sheet
      modules = [
        {
          type = "custom";
          format = "                    ハードウェア                    ";
        }
        {
          type = "custom";
          format = "┌──────────────────────────────────────────────────┐";
        }

        {
          type = "cpu";
          key = "  ";
        }
        {
          type = "gpu";
          key = " GPU ";
          format = "{2} [{6}]";
        }
        {
          type = "memory";
          key = " MEM ";
        }
        {
          type = "display";
          key = "  ";
        }
        {
          type = "disk";
          key = " 󰋊 ";
        }

        {
          type = "custom";
          format = "└──────────────────────────────────────────────────┘";
        }
        "break"

        {
          type = "custom";
          format = "                    ソフトウェア                    ";
        }
        {
          type = "custom";
          format = "┌──────────────────────────────────────────────────┐";
        }

        {
          type = "title";
          key = " 󰁥 ";
          format = "{1}@{2}";
        }
        "break"
        {
          type = "os";
          key = "  ";
        }
        {
          type = "kernel";
          key = " 󰌽 ";
          format = "{1} {2}";
        }
        {
          type = "packages";
          key = " 󰆧 ";
        }
        "break"
        {
          type = "terminal";
          key = "  ";
        }
        {
          type = "shell";
          key = " 󱆃 ";
        }
        {
          type = "font";
          key = " 󰬈 ";
        }
        "break"
        {
          type = "de";
          key = "  ";
        }
        {
          type = "wm";
          key = "  ";
        }
        {
          type = "wmtheme";
          key = "  ";
        }
        {
          type = "theme";
          key = " 󰏘 ";
        }
        {
          type = "icons";
          key = "  ";
        }
        {
          type = "cursor";
          key = " 󰇀 ";
        }
        "break"
        {
          type = "media";
          key = " 󰝚 ";
        }
        {
          type = "custom";
          format = "└──────────────────────────────────────────────────┘";
        }
      ];
    };
  };
}
