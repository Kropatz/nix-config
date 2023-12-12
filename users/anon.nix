{ pkgs, inputs, vars, ... }:
let 
  user = "anon";
in
{
  imports = [
    (import ../home-manager/nvim.nix ({ user="${user}"; pkgs = pkgs; }))
    (import ../home-manager/direnv.nix ({ user="${user}"; pkgs = pkgs; }))
    (import ../home-manager/zsh.nix ({ user="${user}"; pkgs = pkgs; }))
  ];
  mainUser.name = user;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
    useUserPackages = true;
    users.${user} = {
      programs.git.enable = true;
      home.stateVersion = "23.05";
    };
  };
  
  programs.zsh.enable = true;
  users.users.${user} = {
    isNormalUser = true;
    description = user;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark"];
    packages = with pkgs; [
      firefox
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 lukas"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuRAKtoU5rjSbjDxlac6oAww/XHgsVRFHwIVnVm/TrTtDNqRyAkr6fIUiSKTHrpBPyJjIKCzkHS8QhbS2zZo4wjcgAyMyK33q/CzLs8DPQMWX0RKxR+OaVNwh90iWHr663a5x7ztTag3oPGOAYjeqCoIJWyQRlvIKflriJnAjWE8nvw4QkErpRWo4JJnhS61GQMrPT6VK0yXzq3zQs2t3cXTvGMmeLjBuluvJ6yiDk2bAGdY2UWnbs1y2M1TD3xn0pHzITeQnoWLfy+cwPHnEulciVqyr4pp6LDygmIPI1rxKAIQUnwo09n/A1eIcqlUo8aKy7ZDyrssuGWKZ/U4FC258NWwdUPbjyQvzNdcZjXC4+AmQTb+DwiECYOCfF7O/uRRqoFl7jfVfKqHJ7DKebt20QKwDCH/d5qfDs6xA0Krl2dgu3vePhsOkmpnIfPk9Cxl+YHGfmpCOVQHhxCwpkQs0Oh7NerO3idnG1enckjCuzCotnL8vDhczdL4eZmus= kopatz@nix-laptop
"
    ];
  };
}
