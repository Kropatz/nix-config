{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "hardening";
  cfg = config.custom.misc.${name};
in
{

  options.custom.misc.${name} = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable hardening options.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = [
      "debugfs=off"
    ];
    security.protectKernelImage = true;
    security.pam.services = {
      su.requireWheel = lib.mkDefault true;
      su-l.requireWheel = lib.mkDefault true;
    };
    # https://github.com/Kicksecure/security-misc/blob/master/etc/modprobe.d/30_security-misc_disable.conf%23security-misc-shared
    environment.etc."modprobe.d/nm-module-blacklist.conf".text = ''
      ## FireWire (IEEE 1394):
      ## Disable IEEE 1394 (FireWire/i.LINK/Lynx) modules to prevent certain DMA attacks.
      ##
      ## https://en.wikipedia.org/wiki/IEEE_1394#Security_issues
      ##
      install dv1394 /usr/bin/disabled-firewire-by-security-misc
      install firewire-core /usr/bin/disabled-firewire-by-security-misc
      install firewire-ohci /usr/bin/disabled-firewire-by-security-misc
      install firewire-net /usr/bin/disabled-firewire-by-security-misc
      install firewire-sbp2 /usr/bin/disabled-firewire-by-security-misc
      install ohci1394 /usr/bin/disabled-firewire-by-security-misc
      install raw1394 /usr/bin/disabled-firewire-by-security-misc
      install sbp2 /usr/bin/disabled-firewire-by-security-misc
      install video1394 /usr/bin/disabled-firewire-by-security-misc

      ## Global Positioning Systems (GPS):
      ## Disable GPS-related modules like GNSS (Global Navigation Satellite System).
      ##
      install garmin_gps /usr/bin/disabled-gps-by-security-misc
      install gnss /usr/bin/disabled-gps-by-security-misc
      install gnss-mtk /usr/bin/disabled-gps-by-security-misc
      install gnss-serial /usr/bin/disabled-gps-by-security-misc
      install gnss-sirf /usr/bin/disabled-gps-by-security-misc
      install gnss-ubx /usr/bin/disabled-gps-by-security-misc
      install gnss-usb /usr/bin/disabled-gps-by-security-misc

      ## Intel Platform Monitoring Technology (PMT) Telemetry:
      ## Disable certain functionalities of the Intel PMT components.
      ##
      ## https://www.intel.com/content/www/us/en/content-details/710389/intel-platform-monitoring-technology-intel-pmt-technical-specification.html
      ## https://github.com/intel/Intel-PMT
      ##
      install pmt_class /usr/bin/disabled-intelpmt-by-security-misc
      install pmt_crashlog /usr/bin/disabled-intelpmt-by-security-misc
      install pmt_telemetry /usr/bin/disabled-intelpmt-by-security-misc

      ## Thunderbolt:
      ## Disable Thunderbolt modules to prevent certain DMA attacks.
      ##
      ## https://en.wikipedia.org/wiki/Thunderbolt_(interface)#Security_vulnerabilities
      ##
      install intel-wmi-thunderbolt /usr/bin/disabled-thunderbolt-by-security-misc
      install thunderbolt /usr/bin/disabled-thunderbolt-by-security-misc
      install thunderbolt_net /usr/bin/disabled-thunderbolt-by-security-misc

      ## 2. File Systems:

      ## File Systems:
      ## Disable uncommon file systems to reduce attack surface.
      ## HFS/HFS+ are legacy Apple file systems that may be required depending on the EFI partition format.
      ##
      ## https://docs.kernel.org/filesystems/index.html
      ## https://github.com/secureblue/secureblue/tree/live/files/system/usr/lib/modprobe.d
      ##
      install adfs /usr/bin/disabled-filesys-by-security-misc
      install affs /usr/bin/disabled-filesys-by-security-misc
      install afs /usr/bin/disabled-filesys-by-security-misc
      install befs /usr/bin/disabled-filesys-by-security-misc
      install ceph /usr/bin/disabled-filesys-by-security-misc
      install coda /usr/bin/disabled-filesys-by-security-misc
      install cramfs /usr/bin/disabled-filesys-by-security-misc
      install ecryptfs /usr/bin/disabled-filesys-by-security-misc
      install freevxfs /usr/bin/disabled-filesys-by-security-misc
      install hfs /usr/bin/disabled-filesys-by-security-misc
      install hfsplus /usr/bin/disabled-filesys-by-security-misc
      install jffs2 /usr/bin/disabled-filesys-by-security-misc
      install jfs /usr/bin/disabled-filesys-by-security-misc
      install kafs /usr/bin/disabled-filesys-by-security-misc
      install minix /usr/bin/disabled-filesys-by-security-misc
      install nilfs2 /usr/bin/disabled-filesys-by-security-misc
      install ocfs2 /usr/bin/disabled-filesys-by-security-misc
      install orangefs /usr/bin/disabled-filesys-by-security-misc
      install reiserfs /usr/bin/disabled-filesys-by-security-misc
      install romfs /usr/bin/disabled-filesys-by-security-misc
      install sysv /usr/bin/disabled-filesys-by-security-misc
      install ubifs /usr/bin/disabled-filesys-by-security-misc
      install udf /usr/bin/disabled-filesys-by-security-misc
      install ufs /usr/bin/disabled-filesys-by-security-misc
      install zonefs /usr/bin/disabled-filesys-by-security-misc

      ## Network File Systems:
      ## Disable uncommon network file systems to reduce attack surface.
      ## Currently 9p is required for KVM shared folders in Whonix.
      ##
      ## https://www.whonix.org/wiki/KVM#Shared_Folder
      ##
      #install 9p /usr/bin/disabled-netfilesys-by-security-misc
      install gfs2 /usr/bin/disabled-netfilesys-by-security-misc
      install ksmbd /usr/bin/disabled-netfilesys-by-security-misc

      ## Network File System - Common Internet File System (CIFS):
      ##
      install cifs /usr/bin/disabled-netfilesys-by-security-misc
      install cifs_arc4 /usr/bin/disabled-netfilesys-by-security-misc
      install cifs_md4 /usr/bin/disabled-netfilesys-by-security-misc

      ## Network File System - Network File System (NFS):
      ##
      install nfs /usr/bin/disabled-netfilesys-by-security-misc
      install nfs_acl /usr/bin/disabled-netfilesys-by-security-misc
      install nfs_layout_nfsv41_files /usr/bin/disabled-netfilesys-by-security-misc
      install nfs_layout_flexfiles /usr/bin/disabled-netfilesys-by-security-misc
      install nfsd /usr/bin/disabled-netfilesys-by-security-misc
      install nfsv2 /usr/bin/disabled-netfilesys-by-security-misc
      install nfsv3 /usr/bin/disabled-netfilesys-by-security-misc
      install nfsv4 /usr/bin/disabled-netfilesys-by-security-misc

      ## 2. Networking:

      ## Network Protocols:
      ## Disable rare and unneeded network protocols that are a common source of unknown vulnerabilities.
      ## Previously had blacklisted eepro100 and eth1394.
      ##
      ## https://tails.boum.org/blueprint/blacklist_modules/
      ## https://fedoraproject.org/wiki/Security_Features_Matrix#Blacklist_Rare_Protocols
      ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-rare-network.conf?h=ubuntu/disco
      ## https://github.com/Kicksecure/security-misc/pull/234#issuecomment-2230732015
      ##
      install af_802154 /usr/bin/disabled-network-by-security-misc
      install appletalk /usr/bin/disabled-network-by-security-misc
      install ax25 /usr/bin/disabled-network-by-security-misc
      install decnet /usr/bin/disabled-network-by-security-misc
      install dccp /usr/bin/disabled-network-by-security-misc
      install econet /usr/bin/disabled-network-by-security-misc
      install eepro100 /usr/bin/disabled-network-by-security-misc
      install eth1394 /usr/bin/disabled-network-by-security-misc
      install ipx /usr/bin/disabled-network-by-security-misc
      install n-hdlc /usr/bin/disabled-network-by-security-misc
      install netrom /usr/bin/disabled-network-by-security-misc
      install p8022 /usr/bin/disabled-network-by-security-misc
      install p8023 /usr/bin/disabled-network-by-security-misc
      install psnap /usr/bin/disabled-network-by-security-misc
      install rose /usr/bin/disabled-network-by-security-misc
      install x25 /usr/bin/disabled-network-by-security-misc

      ## Network Protocol - Asynchronous Transfer Mode (ATM):
      ##
      install atm /usr/bin/disabled-network-by-security-misc
      install ueagle-atm /usr/bin/disabled-network-by-security-misc
      install usbatm /usr/bin/disabled-network-by-security-misc
      install xusbatm /usr/bin/disabled-network-by-security-misc

      ## Network Protocol - Controller Area Network (CAN):
      ##
      install c_can /usr/bin/disabled-network-by-security-misc
      install c_can_pci /usr/bin/disabled-network-by-security-misc
      install c_can_platform /usr/bin/disabled-network-by-security-misc
      install can /usr/bin/disabled-network-by-security-misc
      install can-bcm /usr/bin/disabled-network-by-security-misc
      install can-dev /usr/bin/disabled-network-by-security-misc
      install can-gw /usr/bin/disabled-network-by-security-misc
      install can-isotp /usr/bin/disabled-network-by-security-misc
      install can-raw /usr/bin/disabled-network-by-security-misc
      install can-j1939 /usr/bin/disabled-network-by-security-misc
      install can327 /usr/bin/disabled-network-by-security-misc
      install ifi_canfd /usr/bin/disabled-network-by-security-misc
      install janz-ican3 /usr/bin/disabled-network-by-security-misc
      install m_can /usr/bin/disabled-network-by-security-misc
      install m_can_pci /usr/bin/disabled-network-by-security-misc
      install m_can_platform /usr/bin/disabled-network-by-security-misc
      install phy-can-transceiver /usr/bin/disabled-network-by-security-misc
      install slcan /usr/bin/disabled-network-by-security-misc
      install ucan /usr/bin/disabled-network-by-security-misc
      install vxcan /usr/bin/disabled-network-by-security-misc
      install vcan /usr/bin/disabled-network-by-security-misc

      ## Network Protocol - Transparent Inter Process Communication (TIPC):
      ##
      install tipc /usr/bin/disabled-network-by-security-misc
      install tipc_diag /usr/bin/disabled-network-by-security-misc

      ## Network Protocol - Reliable Datagram Sockets (RDS):
      ##
      install rds /usr/bin/disabled-network-by-security-misc
      install rds_rdma /usr/bin/disabled-network-by-security-misc
      install rds_tcp /usr/bin/disabled-network-by-security-misc

      ## Network Protocol - Stream Control Transmission Protocol (SCTP):
      ##
      install sctp /usr/bin/disabled-network-by-security-misc
      install sctp_diag /usr/bin/disabled-network-by-security-misc

      ## 4. Miscellaneous:

      ## Amateur Radios:
      ##
      install hamradio /usr/bin/disabled-miscellaneous-by-security-misc

      ## Floppy Disks:
      ##
      install floppy /usr/bin/disabled-miscellaneous-by-security-misc

      ## Framebuffer (fbdev):
      ## Video drivers are known to be buggy, cause kernel panics, and are generally only used by legacy devices.
      ## These were all previously blacklisted.
      ##
      ## https://docs.kernel.org/fb/index.html
      ## https://en.wikipedia.org/wiki/Linux_framebuffer
      ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-framebuffer.conf?h=ubuntu/disco
      ##
      install aty128fb /usr/bin/disabled-framebuffer-by-security-misc
      install atyfb /usr/bin/disabled-framebuffer-by-security-misc
      install cirrusfb /usr/bin/disabled-framebuffer-by-security-misc
      install cyber2000fb /usr/bin/disabled-framebuffer-by-security-misc
      install cyblafb /usr/bin/disabled-framebuffer-by-security-misc
      install gx1fb /usr/bin/disabled-framebuffer-by-security-misc
      install hgafb /usr/bin/disabled-framebuffer-by-security-misc
      install i810fb /usr/bin/disabled-framebuffer-by-security-misc
      install intelfb /usr/bin/disabled-framebuffer-by-security-misc
      install kyrofb /usr/bin/disabled-framebuffer-by-security-misc
      install lxfb /usr/bin/disabled-framebuffer-by-security-misc
      install matroxfb_base /usr/bin/disabled-framebuffer-by-security-misc
      install neofb /usr/bin/disabled-framebuffer-by-security-misc
      install nvidiafb /usr/bin/disabled-framebuffer-by-security-misc
      install pm2fb /usr/bin/disabled-framebuffer-by-security-misc
      install radeonfb /usr/bin/disabled-framebuffer-by-security-misc
      install rivafb /usr/bin/disabled-framebuffer-by-security-misc
      install s1d13xxxfb /usr/bin/disabled-framebuffer-by-security-misc
      install savagefb /usr/bin/disabled-framebuffer-by-security-misc
      install sisfb /usr/bin/disabled-framebuffer-by-security-misc
      install sstfb /usr/bin/disabled-framebuffer-by-security-misc
      install tdfxfb /usr/bin/disabled-framebuffer-by-security-misc
      install tridentfb /usr/bin/disabled-framebuffer-by-security-misc
      install vesafb /usr/bin/disabled-framebuffer-by-security-misc
      install vfb /usr/bin/disabled-framebuffer-by-security-misc
      install viafb /usr/bin/disabled-framebuffer-by-security-misc
      install vt8623fb /usr/bin/disabled-framebuffer-by-security-misc
      install udlfb /usr/bin/disabled-framebuffer-by-security-misc

      ## Joysticks:
      ##
      ## https://docs.kernel.org/input/joydev/joystick.html
      ##
      install joydev /usr/bin/disabled-miscellaneous-by-security-misc

      ## Replaced Modules:
      ## These legacy drivers have all been entirely replaced and superseded by newer drivers.
      ## Many of these were previously blacklisted.
      ##
      ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist.conf?h=ubuntu/disco
      ##
      install asus_acpi /usr/bin/disabled-miscellaneous-by-security-misc
      install bcm43xx /usr/bin/disabled-miscellaneous-by-security-misc
      install brcm80211 /usr/bin/disabled-miscellaneous-by-security-misc
      install de4x5 /usr/bin/disabled-miscellaneous-by-security-misc
      install prism54 /usr/bin/disabled-miscellaneous-by-security-misc

      ## RNDIS:
      ## Disable as believed to have unfixable buffer overflow issues impossible to make secure.
      ## Used by some network devices common with Android USB tethering.
      ##
      ## https://en.wikipedia.org/wiki/RNDIS
      ## https://lkml.org/lkml/2022/11/23/728
      ## https://lore.kernel.org/lkml/2023071333-wildly-playroom-878b@gregkh/
      ##
      install rndis_host /usr/bin/disabled-miscellaneous-by-security-misc
      install usb_f_rndis /usr/bin/disabled-miscellaneous-by-security-misc
    '';
  };
}
