# valheim.nix
{config, pkgs, lib, ...}: let
  join = builtins.concatStringsSep " ";
in {

	networking.firewall.allowedUDPPorts = [ 8211 ]; #5349 ];
	users.users.palworld = {
		isSystemUser = true;
		# Valheim puts save data in the home directory.
		home = "/var/lib/palworld";
		createHome = true;
		homeMode = "750";
		group = "palworld";
	};

	users.groups.palworld = {};

	systemd.services.palworld = {
		wantedBy = [ "multi-user.target" ];

		wants = [ "network-online.target" ];
		after = [ "network-online.target" ];

		serviceConfig = {
			ExecStartPre = join [
				"${pkgs.steamcmd}/bin/steamcmd"
				"+force_install_dir /var/lib/palworld"
          			"+login anonymous"
          			"+app_update 2394010"
          			"+quit"
          			"&& mkdir -p /var/lib/palworld/.steam/sdk64"
          			"&& cp /var/lib/palworld/linux64/steamclient.so /var/lib/palworld/.steam/sdk64/."
			];
			ExecStart = join [
				"${pkgs.steam-run}/bin/steam-run /var/lib/palworld/Pal/Binaries/Linux/PalServer-Linux-Test Pal"
				"--useperfthreads"
				"-NoAsyncLoadingThread"
				"-UseMultithreadForDS"
			];
			Nice = "-5";
			PrivateTmp = true;
			Restart = "always";
			User = "palworld";
			WorkingDirectory = "~";
		};
		environment = {
			# linux64 directory is required by Valheim.
			LD_LIBRARY_PATH = "/var/lib/palworld/linux64:${pkgs.glibc}/lib";
			SteamAppId = "2394010";
		};
	};
}
