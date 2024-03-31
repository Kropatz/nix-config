{ config, ...}:
{
  services.gitolite = {
    enable = true;
    adminPubkey = config.mainUser.sshKey;
  };
}
