{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    typst
    typstwriter
  ];
}
