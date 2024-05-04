# create secrets
`agenix -e secret1.age`


example secrets.nix file
```
let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  users = [ user1 ];

  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  systems = [ system1 ];
in
{
  "secret1.age".publicKeys = [ user1 system1 ];
}
```

use secret in config
```
age.secrets.nextcloud = {
  file = ./secrets/secret1.age;
  owner = "nextcloud";
  group = "nextcloud";
};
services.nextcloud = {
  enable = true;
  package = pkgs.nextcloud25;
  hostName = "localhost";
  config.adminpassFile = config.age.secrets.nextcloud.path;
};
```

# rekeying
`agenix -r`
