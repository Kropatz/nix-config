{ pkgs, lib, osConfig, ... }:
let
  merge = lib.foldr (a: b: a // b) { };
  search = {
    default = "DuckDuckGo";
    force = true;
    engines = {
      # don't need these default ones
      "Amazon.com".metaData.hidden = true;
      "Bing".metaData.hidden = true;
      "eBay".metaData.hidden = true;

      "DuckDuckGo" = {
        urls = [{
          template = "https://duckduckgo.com";
          params = [{
            name = "q";
            value = "{searchTerms}";
          }];
        }];
        definedAliases = [ ",d" ];
      };
      "Nix Packages" = {
        urls = [{
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "type";
              value = "packages";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }];
        definedAliases = [ ",n" ];
      };
      "Wikipedia" = {
        urls = [{
          template = "https://en.wikipedia.org/wiki/Special:Search";
          params = [{
            name = "search";
            value = "{searchTerms}";
          }];
        }];
        definedAliases = [ ",w" ];
      };
      "GitHub" = {
        urls = [{
          template = "https://github.com/search";
          params = [{
            name = "q";
            value = "{searchTerms}";
          }];
        }];
        definedAliases = [ ",gh" ];
      };
    };
  };
in {
  stylix = lib.mkIf osConfig.custom.graphical.stylix.enable {
    targets.firefox = {
      profileNames = [ "default" ];
      colorTheme.enable = true;
    };
  };
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      DisablePocket = true;
      DisableFirefoxStudies = true;
      DisableFeedbackCommands = true;
      Extensions = {
        Uninstall = [
          "google@search.mozilla.org"
          "bing@search.mozilla.org"
          "amazondotcom@search.mozilla.org"
          "ebay@search.mozilla.org"
          "wikipedia@search.mozilla.org"
          "webcompat-reporter@mozilla.org"
          "addons-search-detection@mozilla.com"
        ];
      };
      ExtensionSettings = {
        "google@search.mozilla.org".installation_mode = "blocked";
        "bing@search.mozilla.org".installation_mode = "blocked";
        "amazondotcom@search.mozilla.org".installation_mode = "blocked";
        "ebay@search.mozilla.org".installation_mode = "blocked";
        "wikipedia@search.mozilla.org".installation_mode = "blocked";
        "{5cd68d86-8324-4ab2-9e0d-3afcc60bee5f}" = {
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/animated-pekora-dark-theme/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
    profiles = {
      default = {
        name = "privacy-friendly";
        settings = merge ([
          (import ./config/preferences.nix)
          (import ./config/browser-features.nix)
          (import ./config/privacy.nix)
          (import ./config/tracking.nix)
          (import ./config/tracking-webaudio.nix)
          (import ./config/security.nix)
          (import ./config/speed.nix)
        ] ++ lib.optionals osConfig.custom.hardware.nvidia.enable
          [ (import ./config/nvidia-fixes.nix) ]);
        userChrome = ''
          /* Hide tab bar. Used with Sidebery */
          #TabsToolbar {
            visibility: collapse !important;
          }
        '';
        # Changes the extension storage backend from IDB to json, wipes all data when switching 
        extensions.force = true;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          clearurls
          darkreader
          sponsorblock
          ublock-origin
          keepassxc-browser
          youtube-nonstop
          sidebery
        ];
        inherit search;
      };
      enable-webaudio = {
        name = "privacy-but-enable-webaudio";
        id = 2;
        settings = merge ([
          (import ./config/preferences.nix)
          (import ./config/browser-features.nix)
          (import ./config/privacy.nix)
          (import ./config/tracking.nix)
          (import ./config/security.nix)
          (import ./config/speed.nix)
        ] ++ lib.optionals osConfig.custom.hardware.nvidia.enable
          [ (import ./config/nvidia-fixes.nix) ]);
        userChrome = ''
          /* Hide tab bar. Used with Sidebery */
          #TabsToolbar {
            visibility: collapse !important;
          }
        '';
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          clearurls
          darkreader
          sponsorblock
          ublock-origin
          keepassxc-browser
          youtube-nonstop
          sidebery
        ];
        inherit search;
      };
      # This does not have as strict privacy settings as the default profile.
      # It uses the default firefox settings. Useful when something is not
      # working using the default profile
      shit = {
        name = "trade-privacy-for-convenience";
        id = 1;
        userChrome = ''
          /* Hide tab bar. Used with Sidebery */
          #TabsToolbar {
            visibility: collapse !important;
          }
        '';
        settings = merge
          ([ (import ./config/preferences.nix) (import ./config/speed.nix) ]
            ++ lib.optionals osConfig.custom.hardware.nvidia.enable
            [ (import ./config/nvidia-fixes.nix) ]);
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          clearurls
          darkreader
          sponsorblock
          ublock-origin
          youtube-nonstop
          sidebery
        ];
        inherit search;
      };
    };
  };
  xdg.desktopEntries = {
    firefox-enable-webaudio = {
      name = "Firefox - enabled webaudio";
      genericName = "Web Browser";
      exec = "firefox -P privacy-but-enable-webaudio %U";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
  };
}
