{ pkgs, config, ... }:
let
  # https://wiki.nixos.org/wiki/VR#Patching_AMDGPU_to_allow_high_priority_queues
  amdgpu =
    { pkgs
    , lib
    , kernel ? pkgs.linuxPackages_latest.kernel
    }:

    pkgs.stdenv.mkDerivation {
      pname = "amdgpu-kernel-module";
      inherit (kernel) src version postPatch nativeBuildInputs;

      kernel_dev = kernel.dev;
      kernelVersion = kernel.modDirVersion;

      modulePath = "drivers/gpu/drm/amd/amdgpu";

      buildPhase = ''
        BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

        cp $BUILT_KERNEL/Module.symvers .
        cp $BUILT_KERNEL/.config        .
        cp $kernel_dev/vmlinux          .

        make "-j$NIX_BUILD_CORES" modules_prepare
        make "-j$NIX_BUILD_CORES" M=$modulePath modules
      '';

      installPhase = ''
        make \
          INSTALL_MOD_PATH="$out" \
          XZ="xz -T$NIX_BUILD_CORES" \
          M="$modulePath" \
          modules_install
      '';

      meta = {
        description = "AMD GPU kernel module";
        license = lib.licenses.gpl3;
      };
    };
  amdgpu-kernel-module = pkgs.callPackage amdgpu {
    # Make sure the module targets the same kernel as your system is using.
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  #programs.envision = {
  #  enable = true;
  #  openFirewall = true;
  #};
  #services.monado = {
  #  enable = true;
  #  defaultRuntime = true; # Register as default OpenXR runtime
  #};
  #environment.systemPackages = with pkgs; [
  #  monado
  #];
  #systemd.user.services.monado.environment = {
  #  STEAMVR_LH_ENABLE = "1";
  #  XRT_COMPOSITOR_COMPUTE = "1";
  #};
  #  programs.git = {
  #    enable = true;
  #    lfs.enable = true;
  #  };
  hardware.steam-hardware.enable = true;
  boot.extraModulePackages = [
    (amdgpu-kernel-module.overrideAttrs (_: {
      patches = [
        (pkgs.fetchpatch {
          name = "cap_sys_nice_begone.patch";
          url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
          hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
        })
      ];
    }))
  ];
}
