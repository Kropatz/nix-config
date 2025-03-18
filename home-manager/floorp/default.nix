{ lib, config, osConfig, pkgs, ... }:
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
in
{
  programs.floorp = {
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
    profiles.default = {
      inherit search;
      settings = merge ([
        (import ../firefox/config/preferences.nix)
        (import ../firefox/config/browser-features.nix)
        (import ../firefox/config/privacy.nix)
        (import ../firefox/config/tracking.nix)
        (import ../firefox/config/tracking-webaudio.nix)
        (import ../firefox/config/security.nix)
        (import ../firefox/config/speed.nix)
        (import ./floorp-config.nix)
      ] ++ lib.optionals osConfig.custom.hardware.nvidia.enable
        [ (import ../firefox/config/nvidia-fixes.nix) ]);
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
    };
    profiles.standard = {
      id = 2;
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
    };
  };
}
