let
  laptop-user = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuRAKtoU5rjSbjDxlac6oAww/XHgsVRFHwIVnVm/TrTtDNqRyAkr6fIUiSKTHrpBPyJjIKCzkHS8QhbS2zZo4wjcgAyMyK33q/CzLs8DPQMWX0RKxR+OaVNwh90iWHr663a5x7ztTag3oPGOAYjeqCoIJWyQRlvIKflriJnAjWE8nvw4QkErpRWo4JJnhS61GQMrPT6VK0yXzq3zQs2t3cXTvGMmeLjBuluvJ6yiDk2bAGdY2UWnbs1y2M1TD3xn0pHzITeQnoWLfy+cwPHnEulciVqyr4pp6LDygmIPI1rxKAIQUnwo09n/A1eIcqlUo8aKy7ZDyrssuGWKZ/U4FC258NWwdUPbjyQvzNdcZjXC4+AmQTb+DwiECYOCfF7O/uRRqoFl7jfVfKqHJ7DKebt20QKwDCH/d5qfDs6xA0Krl2dgu3vePhsOkmpnIfPk9Cxl+YHGfmpCOVQHhxCwpkQs0Oh7NerO3idnG1enckjCuzCotnL8vDhczdL4eZmus= kopatz@framework";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINXJG+MciJHOKSPGkrmVB/+TmWA6GNvXI6IAEkt5wNzV root@framework-no-gpu";
  users = [ laptop-user ];
  systems = [ laptop ];
in
{
  "wireguard-private.age".publicKeys = [
    laptop-user
    laptop
  ];
}
