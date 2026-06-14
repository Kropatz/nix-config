{
  services.openssh.enable = true;
  services.openssh.extraConfig = ''
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedAlgorithms +ssh-rsa
  '';

  services.openssh.settings.Macs = [
    "hmac-md5"
  ];
  services.openssh.settings.Ciphers = [
    "3des-cbc"
    "aes128-cbc"
    "aes192-cbc"
    "aes256-cbc"
    "aes128-ctr"
    "aes192-ctr"
    "aes256-ctr"
    "aes128-gcm@openssh.com"
    "aes256-gcm@openssh.com"
    "chacha20-poly1305@openssh.com"
  ];

  services.openssh.settings.KexAlgorithms = [
    "diffie-hellman-group1-sha1"
    "diffie-hellman-group14-sha1"
    "diffie-hellman-group14-sha256"
    "diffie-hellman-group16-sha512"
    "diffie-hellman-group18-sha512"
    "diffie-hellman-group-exchange-sha1"
    "diffie-hellman-group-exchange-sha256"
    "ecdh-sha2-nistp256"
    "ecdh-sha2-nistp384"
    "ecdh-sha2-nistp521"
    "curve25519-sha256"
    "curve25519-sha256@libssh.org"
    "sntrup761x25519-sha512@openssh.com"
  ];
  services.atftpd.enable = true;
}
