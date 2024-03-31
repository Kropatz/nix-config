{ config, ...}:
{
  # configure git clone gitolite@server:gitolite-admin
  # help ssh gitolite@server help
  services.gitolite = {
    enable = true;
    adminPubkey = config.mainUser.sshKey;
  };
}
