{ pkgs, ... }:
{
  powerManagement.powerUpCommands = ''
    		${pkgs.hdparm}/sbin/hdparm -B 127 /dev/sd[ab]
    		${pkgs.hdparm}/sbin/hdparm -S 120 /dev/sd[ab]
    	'';
}
