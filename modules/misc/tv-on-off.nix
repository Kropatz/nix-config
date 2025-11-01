{ pkgs, lib, ... }:
let
  cec = "${pkgs.v4l-utils}/bin/cec-ctl";

  tvOn = pkgs.writeShellScriptBin "tvOn" ''
    if [ $(${cec} -A | ${pkgs.gnugrep}/bin/grep cec0 | ${pkgs.coreutils}/bin/wc -l) -gt 0 ]; then
      ${cec} --tv --skip-info
      ${cec} --skip-info --user-control-pressed ui-cmd=power-on-function --to TV
      echo "Turning TV on!"
    fi
  '';
  tvOff = pkgs.writeShellScriptBin "tvOff" ''
    if [ $(${cec} -A | ${pkgs.gnugrep}/bin/grep cec0 | ${pkgs.coreutils}/bin/wc -l) -gt 0 ]; then
      ${cec} --tv --skip-info
      ${cec} --skip-info --user-control-pressed ui-cmd=power-on-function --to TV
      echo "Turning TV on!"
    fi
  '';
in
{
  environment.systemPackages = with pkgs; [
    tvOff
    tvOn
  ];
  # after suspend, do `cec-ctl -A | grep cec0 | wc -l`, if >0, do `cec-ctl --standby --to TV`
  # similar on wakeup, if present send `cec-ctl --user-control-pressed ui-cmd=power-on-function --to TV`
  environment.etc."systemd/system-sleep/sleep-turn-tv-off-on.sh".source =
    pkgs.writeShellScript "post-sleep-turn-tv-off.sh" ''
      case $1/$2 in
        pre/*)
          ${tvOff}
          ;;
        post/*)
          ${tvOn}
          ;;
      esac
    '';
}
