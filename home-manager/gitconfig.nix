{ config, pkgs, inputs, ...}:
{
  home.file.".gitconfig" = {
    enable = true;
    source = ./.gitconfig;
    target = ".gitconfig";
  };
  home.file.".gitconfig-github" = {
    enable = true;
    source = ./.gitconfig-github;
    target = ".gitconfig-github";
  };
  home.file.".gitconfig-selfhosted" = {
    enable = true;
    source = ./.gitconfig-selfhosted;
    target = ".gitconfig-selfhosted";
  };
  home.file.".gitconfig-gitlabfh" = {
    enable = true;
    source = ./.gitconfig-gitlabfh;
    target = ".gitconfig-gitlabfh";
  };
  home.file.".gitconfig-evolit" = {
    enable = true;
    source = ./.gitconfig-evolit;
    target = ".gitconfig-evolit";
  };
}
