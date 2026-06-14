{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
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
in
{

  options.custom.services.smartd = {
    enable = lib.mkEnableOption "Enables smartd monitoring";
  };
}
