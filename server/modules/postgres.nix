{ pkgs, ... }:
{
    services.postgresql = {
        enable = true;
  	authentication = pkgs.lib.mkOverride 10 ''
    		#type database  DBuser  auth-method optional_ident_map
    		local sameuser  all     peer        map=superuser_map
  	'';
        identMap = ''
                # ArbitraryMapName systemUser DBUser
                superuser_map      root      postgres
                superuser_map      postgres  postgres
                # Let other names login as themselves
                superuser_map      /^(.*)$   \1
        '';
    };
   services.postgresqlBackup = {
	enable = true;
	location = "/var/backup/postgresql";
	backupAll = true;
   }; 
}
