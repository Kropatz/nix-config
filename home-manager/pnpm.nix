{ ... }:
{
  xdg.configFile."pnpm/rc".text = ''
    minimumReleaseAge=7200
    blockExoticSubdeps=true
    trustPolicy=no-downgrade
  '';
}
