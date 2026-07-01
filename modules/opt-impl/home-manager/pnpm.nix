{ ... }:
{
  xdg.configFile."pnpm/config.yaml".text = ''
    minimumReleaseAge: 7200
    blockExoticSubdeps: true
    trustPolicy: no-downgrade
    minimumReleaseAgeIgnoreMissingTime: false
    minimumReleaseAgeStrict: true
  '';
  home.sessionPath = [
    "$HOME/.local/share/pnpm/bin"
  ];
  home.sessionVariables = {
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };
}
