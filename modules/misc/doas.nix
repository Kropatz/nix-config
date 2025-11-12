{pkgs, lib, ...}: {
  security.sudo.enable = false;
  security.doas ={ 
    enable = true;
    extraConfig = ''
      permit persist :wheel
    '';
  };
}
