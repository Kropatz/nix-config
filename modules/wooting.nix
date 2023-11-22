{ pkgs, ...}:
{
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", TAG+="uaccess"
  '';  
  
  environment.systemPackages = with pkgs; [
    wootility
  ];
}
