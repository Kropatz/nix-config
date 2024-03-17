{pkgs, ...}:
{
  #services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    #pinentryFlavor = "qt";
  };
  #environment.systemPackages = with pkgs; [
  #  pinentry-curses
 # ];
}
