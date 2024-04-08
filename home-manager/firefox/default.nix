{ pkgs, lib, ... }:
let merge = lib.foldr (a: b: a // b) { };
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
        params = [
          { name = "q"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ ",d" ];
    };
    "Nix Packages" = {
      urls = [{
        template = "https://search.nixos.org/packages";
        params = [
          { name = "type"; value = "packages"; }
          { name = "query"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ ",n" ];
    };
    "Wikipedia" = {
      urls = [{
        template = "https://en.wikipedia.org/wiki/Special:Search";
        params = [
          { name = "search"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ ",w" ];
    };
    "GitHub" = {
      urls = [{
        template = "https://github.com/search";
        params = [
          { name = "q"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ ",gh" ];
    };
  };
};
in {
  programs.firefox = {
    enable = true;
    package = if pkgs.stdenv.isLinux then pkgs.firefox else pkgs.firefox-bin;
    profiles = {
      default = {
        name = "privacy-friendly";
        settings = merge [
          (import ./config/annoyances.nix)
          (import ./config/browser-features.nix)
          (import ./config/privacy.nix)
          (import ./config/tracking.nix)
          (import ./config/security.nix)
        ];
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          clearurls
          darkreader
          sponsorblock
          ublock-origin
          keepassxc-browser
          youtube-nonstop
        ];
        inherit search;
      };
      # This does not have as strict privacy settings as the default profile.
      # It uses the default firefox settings. Useful when something is not
      # working using the default profile
      shit = {
        name = "trade-privacy-for-convenience";
        id = 1;
        settings = merge [ (import ./config/annoyances.nix) ];
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          clearurls
          darkreader
          sponsorblock
          ublock-origin
          youtube-nonstop
        ];
        inherit search;
      };
    };
  };
}
