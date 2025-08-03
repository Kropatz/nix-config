{ pkgs, lib, config, ... }:
let
  #amdgpu_module_pkg =
  #    { pkgs, lib, fetchurl, kernel ? pkgs.linuxPackages_latest.kernel, ... }:
  #
  #    pkgs.stdenv.mkDerivation {
  #      pname = "amdgpu-kernel-module";
  #      inherit (kernel) version postPatch nativeBuildInputs;
  #      src = fetchurl {
  #        url =
  #          "https://gitlab.freedesktop.org/agd5f/linux/-/archive/amd-drm-next-6.15-2025-03-14/linux-amd-drm-next-6.15-2025-03-14.tar.gz";
  #        # After the first build attempt, look for "hash mismatch" and then 2 lines below at the "got:" line.
  #        # Use "sha256-....." value here.
  #        hash = "sha256-/9EvJNBSKteXljrZzmaQkbZ7o4etCe0yFM3JJg/jD7o=";
  #      };
  #
  #      kernel_dev = kernel.dev;
  #      kernelVersion = kernel.modDirVersion;
  #
  #      modulePath = "drivers/gpu/drm/amd/amdgpu";
  #
  #      buildPhase = ''
  #        BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build
  #
  #        cp $BUILT_KERNEL/Module.symvers .
  #        cp $BUILT_KERNEL/.config        .
  #        cp $kernel_dev/vmlinux          .
  #
  #        make "-j$NIX_BUILD_CORES" modules_prepare
  #        make "-j$NIX_BUILD_CORES" M=$modulePath modules
  #      '';
  #
  #      installPhase = ''
  #        make \
  #          INSTALL_MOD_PATH="$out" \
  #          XZ="xz -T$NIX_BUILD_CORES" \
  #          M="$modulePath" \
  #          modules_install
  #      '';
  #
  #      meta = {
  #        description = "AMD GPU kernel module";
  #        license = lib.licenses.gpl3;
  #      };
  #    };
  #  amdgpu_module = pkgs.callPackage amdgpu_module_pkg {
  #    kernel = config.boot.kernelPackages.kernel;
  #  };
  amd_drm_next_pkg = { fetchurl, buildLinux, ... }@args:

    buildLinux (args // rec {
      version = "6.14.0-rc6";
      modDirVersion = version;

      src = fetchurl {
        url =
          "https://gitlab.freedesktop.org/agd5f/linux/-/archive/amd-drm-fixes-6.15-2025-04-09/linux-amd-drm-fixes-6.15-2025-04-09.tar.gz";
        #"https://gitlab.freedesktop.org/agd5f/linux/-/archive/amd-drm-next-6.15-2025-03-21/linux-amd-drm-next-6.15-2025-03-21.tar.gz";
        hash = "sha256-AhyDuV9KufqDJEJ+Fp+jnAta3OM/a9OcMNG9UV+OgR0=";
      };
      kernelPatches = [ ];

      extraMeta.branch = "6.14.0-rc6";
    } // (args.argsOverride or { }));
  linux_amd_drm_next = pkgs.callPackage amd_drm_next_pkg { };

  linux_6_14 = pkgs.buildLinux {
    version = "6.14.2";
    extraMeta.branch = "6.14";
    src = pkgs.fetchzip {
      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.2.tar.xz";
      hash = "sha256-RytIKSDT9BMRBZvJER19QAShIqfnpwk59CMFKKgipAU=";
    };
  };

  linux_6_16 = pkgs.buildLinux {
    version = "6.16.0";
    extraMeta.branch = "6.16";
    src = pkgs.fetchzip {
      url = "mirror://kernel/linux/kernel/v6.x/linux-6.16.tar.xz";
      hash = "sha256:10ydzfzc3g0nhns6md08gpfshhjcyd58lylqr15alijjdgzf4jqs";
    };
    #src = pkgs.fetchzip {
    #  url = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-6.15.tar.gz";
    #  hash = "sha256:10ydzfzc3g0nhns6md08gpfshhjcyd58lylqr15alijjdgzf4jqs";
    #};
  };

in
{
  #boot.extraModulePackages = [ amdgpu_module ];
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxPackages_testing;
  #boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_13.override {
  #  argsOverride = rec {
  #    src = pkgs.fetchurl {
  #      url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
  #      sha256 = "07c08x68fgcsgriss5z8w427h69y52s887vas91jzb5p70hbcf9s";
  #    };
  #    version = "6.13.7";
  #    modDirVersion = "6.13.7";
  #  };
  #});

  #boot.kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor (linux_6_15.override {
  #  structuredExtraConfig = with lib.kernel; {
  #    SCHED_DEBUG = lib.mkForce unset;
  #  };
  #}));

  boot.kernelPackages = pkgs.linuxPackagesFor linux_6_16;

  #boot.kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor (linux_amd_drm_next.override {
  #  structuredExtraConfig = with lib.kernel; {
  #    SCHED_DEBUG = lib.mkForce unset;
  #  };
  #}));
  #boot.kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_6_14);
}
