{ config, pkgs, inputs, system, lib, ... }:
let
  notifyScript = pkgs.writeScript "smartd-notify.sh" ''
    #!${pkgs.runtimeShell}
    source ${config.age.secrets.webhook-smartd.path}
    MSG=$(
      ${pkgs.coreutils}/bin/cat <<EOF
    **Problem detected with disk**: $SMARTD_DEVICESTRING
    **Warning message from smartd is**:
    $SMARTD_FULLMESSAGE
    EOF
    )
    JSON=$(${pkgs.jq}/bin/jq -n --arg msg "$MSG" '{content: $msg}')
    ${pkgs.curl}/bin/curl --request POST \
    	--url "$WEBHOOK_URL" \
    	--header 'Content-Type: application/json' \
    	--data "$JSON"
  '';
  cfg = config.custom.services.smartd;
in {

  options.custom.services.smartd = {
    enable = lib.mkEnableOption "Enables smartd monitoring";
  };
  config = lib.mkIf cfg.enable {
    age.secrets.webhook-smartd = {
      file = ../../secrets/webhook.age; #File contains WEBHOOK_URL="https://discord.com/api/webhooks/..."
      owner = "root";
      group = "root";
      mode = "400";
    };

    services.smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        x11.enable = false;
        wall.enable = false;
        mail.enable = false;
      };
      defaults.autodetected =
        "-a -o on -s (S/../.././02|L/../../7/04) -m <nomailer> -M exec ${notifyScript} -M test";
    };
  };
}
