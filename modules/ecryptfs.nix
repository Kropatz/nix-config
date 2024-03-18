{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    ecryptfs
  ];
  security.pam.enableEcryptfs = true;

  programs.ecryptfs.enable = true;
  boot.kernelModules = ["ecryptfs"];
}
