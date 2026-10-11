{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.hardware.usb-recovery;

  # Watches the kernel log for "usb X-portN: unable to enumerate USB device"
  # and escalates: short port power cycle -> long power cycle -> controller rebind.
  watchdog = pkgs.writeShellApplication {
    name = "usb-recovery";
    runtimeInputs = with pkgs; [
      uhubctl
      systemd
      coreutils
    ];
    text = ''
      re='^usb (usb)?([0-9.-]+)-port([0-9]+): unable to enumerate USB device'
      declare -A last level
      cooldown_until=0

      journalctl -k -f -n0 -o cat | while IFS= read -r line; do
        [[ $line =~ $re ]] || continue
        hub=''${BASH_REMATCH[2]}
        port=''${BASH_REMATCH[3]}
        key="$hub-port$port"
        now=$(date +%s)
        (( now < cooldown_until )) && continue

        # start over if this port has been quiet for a while
        (( now - ''${last[$key]:-0} > 300 )) && level[$key]=0
        level[$key]=$(( ''${level[$key]:-0} + 1 ))
        last[$key]=$now

        case ''${level[$key]} in
          1) echo "$key: power cycling (5s)"
             uhubctl -f -l "$hub" -p "$port" -a cycle -d 5 || true ;;
          2) echo "$key: power cycling (30s)"
             uhubctl -f -l "$hub" -p "$port" -a cycle -d 30 || true ;;
          3)
            if ${lib.boolToString cfg.resetController}; then
              pci=$(basename "$(readlink -f "/sys/bus/usb/devices/usb''${hub%%-*}/..")")
              echo "$key: rebinding xHCI controller $pci"
              echo "$pci" > /sys/bus/pci/drivers/xhci_hcd/unbind || true
              sleep 3
              echo "$pci" > /sys/bus/pci/drivers/xhci_hcd/bind || true
              cooldown_until=$(( $(date +%s) + 60 ))
            else
              echo "$key: power cycling (30s)"
              uhubctl -f -l "$hub" -p "$port" -a cycle -d 30 || true
            fi ;;
          4) echo "$key: giving up until the port has been quiet for 5 minutes" ;;
        esac
      done
    '';
  };

  quirks = lib.concatMapStringsSep "," (id: "${id}:gk") cfg.noPowerSavingDevices;
in
{
  config = lib.mkIf cfg.enable {
    # g = delay init, k = no LPM
    boot.kernelParams = lib.optional (cfg.noPowerSavingDevices != [ ]) "usbcore.quirks=${quirks}";

    services.udev.extraRules = lib.concatMapStrings (
      id:
      let
        parts = lib.splitString ":" id;
      in
      ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="${lib.elemAt parts 0}", ATTR{idProduct}=="${lib.elemAt parts 1}", TEST=="power/control", ATTR{power/control}="on"
      ''
    ) cfg.noPowerSavingDevices;

    environment.systemPackages = [ pkgs.uhubctl ];

    systemd.services.usb-recovery = {
      description = "Recover USB devices that fail to enumerate";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-journald.service" ];
      serviceConfig = {
        ExecStart = lib.getExe watchdog;
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
