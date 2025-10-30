{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ../default.nix ];
  mainUser.name = "anon";
  mainUser.sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 kopatz";

  home-manager = {
    users.${config.mainUser.name} = import ./home.nix;
  };

  programs.zsh.enable = true;
  users.users.${config.mainUser.name} = {
    isNormalUser = true;
    description = config.mainUser.name;
    shell = pkgs.zsh;
    initialPassword = "cooltemporarypw";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "wireshark"
    ];
    openssh.authorizedKeys.keys = [
      config.mainUser.sshKey
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuRAKtoU5rjSbjDxlac6oAww/XHgsVRFHwIVnVm/TrTtDNqRyAkr6fIUiSKTHrpBPyJjIKCzkHS8QhbS2zZo4wjcgAyMyK33q/CzLs8DPQMWX0RKxR+OaVNwh90iWHr663a5x7ztTag3oPGOAYjeqCoIJWyQRlvIKflriJnAjWE8nvw4QkErpRWo4JJnhS61GQMrPT6VK0yXzq3zQs2t3cXTvGMmeLjBuluvJ6yiDk2bAGdY2UWnbs1y2M1TD3xn0pHzITeQnoWLfy+cwPHnEulciVqyr4pp6LDygmIPI1rxKAIQUnwo09n/A1eIcqlUo8aKy7ZDyrssuGWKZ/U4FC258NWwdUPbjyQvzNdcZjXC4+AmQTb+DwiECYOCfF7O/uRRqoFl7jfVfKqHJ7DKebt20QKwDCH/d5qfDs6xA0Krl2dgu3vePhsOkmpnIfPk9Cxl+YHGfmpCOVQHhxCwpkQs0Oh7NerO3idnG1enckjCuzCotnL8vDhczdL4eZmus= kopatz@framework"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCRCE3RYJ9VQh8QlbPjTnWUc1Q+Vhl6S+HBiKpGeg5pzzN6FdyiZsHWji+HWCtL05Z3QnuVi9CicKXozwFF401FwsoCsVnPmFUQtoyEHOFuGU5RRoXexfw2yBB9XclRNSKPAoqQuXGYd6ukgUeyre/FDABu5MH1H0hnkkYn+ZQU3Y4trYx1FsK5bQ3MXYHTVyHuesODKsLNUYaQTE6VBCsBWTsWWVhRaYuxx/lCfLDwq/IpiwiCEG2kGYoSzRXXft9JlqBKGco0AW/eRnF2vxVfgDchzHbmbT0+oZuJMWDwLqtRzMCJajFp4KILx5DD1YOOaYvwWnEMddaG+I06YRQzqrSBPUJppVCtaEm6a2z/W+RPAsYkiMdmMCIkbSKp9BtjSEdlt/LPa4YChrzDSxZJTe2wmuxCoQFTdg5YezoBpCvzlmju85FhffkOd16mcgnupy92ZoQuVcr3jW6WnLs6gYF2occjdHvRRV1dlQbjpytN1SxJp0zVWGlhJMq36CE= deck@steamdeck"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJ6JEJ5y+Kwf0i3/d+6RKMdblQ8d1W91fstFD5pACHu handy"
    ];
  };
}
