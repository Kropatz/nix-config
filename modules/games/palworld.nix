# valheim.nix
{config, pkgs, lib, ...}: let
in {

	networking.firewall.allowedUDPPorts = [ 8221 ]; #5349 ];
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

		preStart = ''
		   ${pkgs.steamcmd}/bin/steamcmd \
   		     +login anonymous \
   		     +force_install_dir /var/lib/palworld \
   		     +app_update 2394010 validate \
   		     +quit
   		 '';
		script = "${pkgs.steam-run}/bin/steam-run /var/lib/palworld/Pal/Binaries/Linux/PalServer-Linux-Test";

		serviceConfig = {
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
