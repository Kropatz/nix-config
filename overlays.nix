# This file defines overlays
{ inputs, ... }:
let
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
    });
  neotestPatch = ''
     diff --git a/tests/unit/client/strategies/integrated_spec.lua b/tests/unit/client/strategies/integrated_spec.lua
    index 196c2e78..42a3df76 100644
    --- a/tests/unit/client/strategies/integrated_spec.lua
    +++ b/tests/unit/client/strategies/integrated_spec.lua
    @@ -34,7 +34,7 @@ describe("integrated strategy", function()

       a.it("stops the job", function()
         local process = strategy({
    -      command = { "bash", "-c", "sleep 1" },
    +      command = { "bash", "-c", "sleep 10" },
           strategy = {
             height = 10,
             width = 10,
    @@ -47,7 +47,7 @@ describe("integrated strategy", function()

       a.it("streams output", function()
         local process = strategy({
    -      command = { "bash", "-c", "printf hello; sleep 0; printf world" },
    +      command = { "bash", "-c", "printf hello; sleep 0.1; printf world" },
           strategy = {
             height = 10,
             width = 10,
  '';
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ./pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # vencord = prev.vencord.overrideAttrs {
    #
    #   pname = "vencord";
    #   version = "1.14.13";
    #
    #   src = prev.fetchFromGitHub {
    #     owner = "Vendicated";
    #     repo = "Vencord";
    #     tag = "v1.14.13";
    #     hash = "sha256-Xqk/akTa/NcHjSm6h77y6Fkvq7ayBcR0w0HG0Hwfkf8=";
    #   };
    #   pnpmDeps = prev.fetchPnpmDeps {
    #     pname = "vencordaaaa"; # different hash -> download myself to avoid waiting on slow as hell cache
    #     patches = prev.vencord.patches;
    #     postPatch = prev.vencord.postPatch;
    #
    #     src = prev.fetchFromGitHub {
    #       owner = "Vendicated";
    #       repo = "Vencord";
    #       tag = "v1.14.13";
    #       hash = "sha256-Xqk/akTa/NcHjSm6h77y6Fkvq7ayBcR0w0HG0Hwfkf8=";
    #     };
    #     inherit (prev) pnpm;
    #     fetcherVersion = 3;
    #     hash = "sha256-hk1rnNog5xvuIVI0M1ZJ5xrEuk0zcBiYsbROUycdi+A=";
    #   };
    # };
    discord-canary = prev.discord-canary.override { withVencord = true; };
    discord = prev.discord.override { withVencord = true; };
    # postfix = prev.postfix.override { withSQLite = true; };
    #tetrio-desktop = prev.tetrio-desktop.override { withTetrioPlus = true; };
    #xrdp = (import inputs.nixpkgs-working-xrdp {
    #  system = "x86_64-linux";
    #  config.allowUnfree = true;
    #}).xrdp;

    #jetbrains = prev.jetbrains // {
    #  jdk = (import inputs.nixpkgs-working-jetbrains {
    #    system = prev.stdenv.hostPlatform.system;
    #    config.allowUnfree = true;
    #  }).jetbrains.jdk;
    #  jdk-no-jcef = (import inputs.nixpkgs-working-jetbrains {
    #    system = prev.stdenv.hostPlatform.system;
    #    config.allowUnfree = true;
    #  }).jetbrains.jdk-no-jcef;
    #  jdk-no-jcef-17 = (import inputs.nixpkgs-working-jetbrains {
    #    system = prev.stdenv.hostPlatform.system;
    #    config.allowUnfree = true;
    #  }).jetbrains.jdk-no-jcef-17;
    #};

    #hyprshade = prev.hyprshade.overrideAttrs {
    #  version = "4.0.0";
    #  src = prev.fetchFromGitHub {
    #    owner = "loqusion";
    #    repo = "hyprshade";
    #    tag = "4.0.0";
    #    hash = "sha256-NnKhIgDAOKOdEqgHzgLq1MSHG3FDT2AVXJZ53Ozzioc=";
    #  };
    #};
    monado = prev.monado.overrideAttrs (old: {
      cmakeFlags = old.cmakeFlags ++ [
        "-DBUILD_WITH_OPENCV=OFF"
        (prev.lib.cmakeBool "XRT_HAVE_OPENCV" false)
      ];
    });

    python3Packages = prev.python3Packages // {
      dfdiskcache = prev.python3Packages.dfdiskcache.overrideAttrs (old: {
        pythonRelaxDeps = [ "pandas" ];
      });
    };
    python314Packages = prev.python314Packages // {
      dfdiskcache = prev.python314Packages.dfdiskcache.overrideAttrs (old: {
        pythonRelaxDeps = [ "pandas" ];
      });
    };
    python3 = prev.python3 // {
      pkgs = prev.python3.pkgs // {
        dfdiskcache = prev.python314Packages.dfdiskcache.overrideAttrs (old: {
          pythonRelaxDeps = [ "pandas" ];
        });
      };
    };

    # test failure atm
    # openldap = prev.openldap.overrideAttrs (_: {
    #   doCheck = false;
    # });

    # luajitPackages = prev.luajitPackages // {
    #   neotest = prev.luajitPackages.neotest.overrideAttrs {
    #     patches = [ (prev.writeText "neotest-patch" neotestPatch) ];
    #   };
    # };
    # nginxModules.dav is a real derivation (nginx-mod-dav-*), so the patch has
    # to go through overrideAttrs -- an `// { src = ...; }` update leaves
    # drvPath untouched and is silently ignored by the nginx build.
    nginxModules = prev.nginxModules // {
      dav = prev.nginxModules.dav.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.writeText "dav-propfind.patch" ''
            diff --git a/ngx_http_dav_ext_module.c b/ngx_http_dav_ext_module.c
            index cdb213d..5f14246 100644
            --- a/ngx_http_dav_ext_module.c
            +++ b/ngx_http_dav_ext_module.c
            @@ -862,7 +862,7 @@ ngx_http_dav_ext_propfind(ngx_http_request_t *r, ngx_uint_t props)
                     name.len = ngx_de_namelen(&dir);
                     name.data = ngx_de_name(&dir);

            -        if (name.data[0] == '.') {
            +        if ((name.len == 1 && name.data[0] == '.') || (name.len == 2 && name.data[0] == '.' && name.data[1] == '.')) {
                         continue;
                     }
          '')
        ];
      });
    };
    #hyprland = prev.hyprland.override {
    #  debug = true;
    #};
    # hyprland =
    #   inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
    # xdg-desktop-portal-hyprland =
    #   inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    waybar = prev.waybar.overrideAttrs (oldAttrs: {
      version = "v0.15.0";
      src = prev.fetchFromGitHub {
        owner = "Alexays";
        repo = "Waybar";
        rev = "4e207a0cb51a9eb89b4245d90245721f5e39bf06";
        hash = "sha256-0L1elPWYo9yKgEwpXWWVWQyPVU0SW36LkWUR26CksgU=";
      };
      buildInputs = oldAttrs.buildInputs ++ [
        prev.modemmanager
        prev.libcava
      ];
    });

    # to add input capture protocol support (needed for kde connect)
    #hyprland = prev.hyprland.overrideAttrs (oldAttrs: {
    #  src = prev.fetchFromGitHub {
    #    owner = "3l0w";
    #    repo = "Hyprland";
    #    rev = "2464bfc318f83c093784561c6a0afca6871e119e";
    #    hash = "sha256-6MIA9wu9YW/eKsI0UEuP7CgDiribEv9apzr66dHzRME=";
    #    fetchSubmodules = true;
    #  };
    #});
    #hyprland-protocols = prev.hyprland-protocols.overrideAttrs (oldAttrs: {
    #  src = prev.fetchFromGitHub {
    #    owner = "3l0w";
    #    repo = "hyprland-protocols";
    #    rev = "d6bfa25be7b250dc417cbad89f13291efb0375d5";
    #    hash = "sha256-ULzGRSj18xOrTXnvWrkaaHUaMHaJWyXlmLDDw2jruLo=";
    #  };
    #});
    xdg-desktop-portal-hyprland = prev.xdg-desktop-portal-hyprland.overrideAttrs (oldAttrs: {
      src = prev.fetchFromGitHub {
        owner = "SnotacusNexus";
        repo = "xdg-desktop-portal-hyprland";
        rev = "84aacf0f4fdf888eceac0f47909e2b7f690b5d43";
        hash = "sha256-ENi7htGWHdWC7iqZW1AhevQhWc722ZkCHS4hJyJzaWk=";
      };

      patches = [
        (prev.writeText "testing-patch" ''
          --- a/src/shared/ToplevelManager.cpp
          +++ b/src/shared/ToplevelManager.cpp
          @@ -56,5 +56,5 @@ void CToplevelManager::activate() {
           
               wl_display_roundtrip(g_pPortalManager->m_sWaylandConnection.display);
           
          -    Debug::log(LOG, "[toplevel] Activated, bound to {:x}, toplevels: {}", (uintptr_t)m_pManager, m_vToplevels.size());
          +    Debug::log(LOG, "[toplevel] Activated, bound to {:x}, toplevels: {}", (uintptr_t)m_pManager.get(), m_vToplevels.size());
           }
          --- a/src/portals/Screencopy.cpp
          +++ b/src/portals/Screencopy.cpp
          @@ -631,5 +631,5 @@ void CScreencopyPortal::queueNextShareFrame(CScreencopyPortal::SSession* pSessio
                   {std::clamp(MSTILNEXTREFRESH - 1.0 /* safezone */, 6.0, 1000.0), [pSession]() { g_pPortalManager->m_sPortals.screencopy->startFrameCopy(pSession); }});
           }
           bool CScreencopyPortal::hasToplevelCapabilities() {
          -    return m_sState.toplevel;
          +    return static_cast<bool>(m_sState.toplevel);
           }
          --- a/src/portals/RemoteDesktop.cpp
          +++ b/src/portals/RemoteDesktop.cpp
          @@ -471,9 +471,27 @@
                                   eis_device_configure_capability(dev, EIS_DEVICE_CAP_POINTER_ABSOLUTE);
                                   eis_device_configure_capability(dev, EIS_DEVICE_CAP_BUTTON);
                                   eis_device_configure_capability(dev, EIS_DEVICE_CAP_SCROLL);
          +                        // A device with EIS_DEVICE_CAP_POINTER_ABSOLUTE needs at least one region,
          +                        // otherwise libei silently discards every absolute motion event.
          +                        {
          +                            uint32_t extentW = 1920, extentH = 1080;
          +                            if (g_pPortalManager)
          +                                g_pPortalManager->getOutputExtents(extentW, extentH);
          +                            if (auto* region = eis_device_new_region(dev)) {
          +                                eis_region_set_offset(region, 0, 0);
          +                                eis_region_set_size(region, extentW, extentH);
          +                                eis_region_set_physical_scale(region, 1.0);
          +                                eis_region_add(region);
          +                                eis_region_unref(region);
          +                            }
          +                        }
                                   eis_device_add(dev);
          -                        eis_device_start_emulating(dev, 0);
          -                        Debug::log(LOG, "[remotedesktop] EIS pointer device added & emulating");
          +                        // The libei client is a sender (ei_new_sender), so it is the one that
          +                        // calls ei_device_start_emulating(). All we have to do is unpause the
          +                        // device -- eis_device_add() leaves it paused, and eis_device_start_emulating()
          +                        // is receiver-side API that libeis rejects for a sender client.
          +                        eis_device_resume(dev);
          +                        Debug::log(LOG, "[remotedesktop] EIS pointer device added & resumed");
                               }
                           }
                           if (eis_event_seat_has_capability(event, EIS_DEVICE_CAP_KEYBOARD)) {
          @@ -515,8 +533,8 @@
                                       }
                                   }
                                   eis_device_add(dev);
          -                        eis_device_start_emulating(dev, 0);
          -                        Debug::log(LOG, "[remotedesktop] EIS keyboard device added & emulating");
          +                        eis_device_resume(dev);
          +                        Debug::log(LOG, "[remotedesktop] EIS keyboard device added & resumed");
                               }
                           }
                           break;
        '')
      ];
      buildInputs = oldAttrs.buildInputs ++ [ prev.libei ];
    });

    #brotli = prev.brotli.overrideAttrs (oldAttrs: rec {
    #  version = "1.2.1";

    #  src = prev.fetchFromGitHub {
    #    owner = "google";
    #    repo = "brotli";
    #    tag = "v${version}";
    #    hash = "sha256-llY72cYffDv0ugsH0p89xIPEbElV4L8u7U/Fe8hT3gI=";
    #  };
    #});

    #csharp-ls = prev.csharp-ls-8;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable-new {
      system = final.system;
      config.allowUnfree = true;
    };
  };
  # stable-packages = final: _prev: {
  #   stable = import inputs.nixpkgs {
  #     system = final.system;
  #     config.allowUnfree = true;
  #   };
  # };
  # unstable-small-packages = final: _prev: {
  #   unstable-small = import inputs.nixpkgs-unstable-small {
  #     system = final.system;
  #     config.allowUnfree = true;
  #   };
  # };
}
