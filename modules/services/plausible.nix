{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.plausible;
in
{
  options.custom.services.plausible = {
    enable = lib.mkEnableOption "Enables plausible";
  };
  config = lib.mkIf cfg.enable {

    age.secrets.plausible-admin = {
      file = ../../secrets/plausible-admin.age;
    };
    age.secrets.plausible-keybase = {
      file = ../../secrets/plausible-keybase.age;
    };

    services.clickhouse = {
      enable = true;
      extraUsersConfig = ''
        <clickhouse>
          <profiles>
              <default>
                  <log_queries>0</log_queries>
                  <log_query_threads>0</log_query_threads>
              </default>
          </profiles>
        </clickhouse>
      '';
      extraServerConfig = ''
        <clickhouse>
            <logger>
                <level>warning</level>
                <console>true</console>
            </logger>
            <query_thread_log remove="remove"/>
            <query_log remove="remove"/>
            <text_log remove="remove"/>
            <trace_log remove="remove"/>
            <metric_log remove="remove"/>
            <asynchronous_metric_log remove="remove"/>

            <!-- Update: Required for newer versions of Clickhouse -->
            <session_log remove="remove"/>
            <part_log remove="remove"/>
        </clickhouse>
      '';
    };

    services.plausible = {
      enable = true;
      # removed, create on initial setup now
      #adminUser = {
      #  # activate is used to skip the email verification of the admin-user that's
      #  # automatically created by plausible. This is only supported if
      #  # postgresql is configured by the module. This is done by default, but
      #  # can be turned off with services.plausible.database.postgres.setup.
      #  activate = true;
      #  email = "admin@localhost";
      #  passwordFile = config.age.secrets.plausible-admin.path;
      #};
      server = {
        baseUrl = "https://plausible.imbissaggsbachdorf.at";
        #baseUrl = "http://localhost";
        # secretKeybaseFile is a path to the file which contains the secret generated
        # with openssl as described above.
        secretKeybaseFile = config.age.secrets.plausible-keybase.path;
      };
    };

  };
}
