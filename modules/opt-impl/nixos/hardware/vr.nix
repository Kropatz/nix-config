{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.hardware.vr;
  # https://wiki.nixos.org/wiki/VR#Patching_AMDGPU_to_allow_high_priority_queues
  amdgpu =
    {
      pkgs,
      lib,
      kernel ? pkgs.linuxPackages_latest.kernel,
    }:

    pkgs.stdenv.mkDerivation {
      pname = "amdgpu-kernel-module";
      inherit (kernel)
        src
        version
        postPatch
        nativeBuildInputs
        ;

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
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  audio = {
    desktopSink = "alsa_output.usb-Logitech_G733_Gaming_Headset-00.analog-stereo";
    desktopSource = "alsa_input.usb-Razer_Inc._Razer_Seiren_UC1713127402487-00.analog-stereo";
    gpuCard = "alsa_card.pci-0000_03_00.1";
    gpuProfile = "output:hdmi-stereo";
    vrProfile = "output:hdmi-stereo-extra1";
    vrSink = "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra1";
    vrSource = "alsa_input.usb-Valve_Corporation_Valve_VR_Radio___HMD_Mic_48DE54B066-LYM-01.mono-fallback";
  };
  # the headset's HDMI port only shows up once monado has turned the display on
  switchToVrSink = pkgs.writeShellScript "monado-vr-sink" ''
    for _ in {1..30}; do
      ${pactl} set-card-profile ${audio.gpuCard} ${audio.vrProfile} 2>/dev/null &&
        ${pactl} set-default-sink ${audio.vrSink} 2>/dev/null &&
        echo "default sink: ${audio.vrSink}" && exit 0
      sleep 1
    done
    echo "${audio.vrSink} did not appear" >&2
  '';
in
{

  #programs.envision = {
  #  enable = true;
  #  openFirewall = true;
  #};

  # systemctl --user start monado.service
  # make sure ~/.config/openxr/1/active_runtime.json doesn't block it
  # and ~/.config/openvr/openvrpaths.vrpath
  config = lib.mkIf cfg.enable {
    services.monado = {
      enable = true;
      defaultRuntime = true; # Register as default OpenXR runtime
      highPriority = true;
    };
    services.wivrn = {
      enable = true;
      openFirewall = true; # Register as default OpenVR runtime
      # xrizer never reports the trigger as touched for legacy (pre-SteamVR-input) games,
      # which breaks UI clicks in games that check the touched mask
      package = pkgs.unstable.wivrn.override {
        xrizer = pkgs.unstable.xrizer.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./xrizer-legacy-pressed-implies-touched.patch ];
        });
      };
    };
    environment.systemPackages = with pkgs; [
      monado
      wayvr
    ];
    systemd.user.services.monado.environment = {
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
      WMR_HANDTRACKING = "0";
    };
    # switch default audio devices to the headset while monado runs
    systemd.user.services.monado.serviceConfig = {
      ExecStartPost = [
        "-${pactl} set-default-source ${audio.vrSource}"
        "-${switchToVrSink}"
      ];
      ExecStopPost = [
        "-${pactl} set-default-sink ${audio.desktopSink}"
        "-${pactl} set-default-source ${audio.desktopSource}"
        "-${pactl} set-card-profile ${audio.gpuCard} ${audio.gpuProfile}"
      ];
    };
    programs.git = {
      enable = true;
      lfs.enable = true;
    };

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
  };
}
