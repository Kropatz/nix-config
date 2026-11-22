{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.mpv = {
    enable = true;
    config = {
      volume = 50;
      # uosc draws its own controls and seek bar
      osc = "no";
      osd-bar = "no";
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      uosc # modern controls; its timeline shows A-B loop marks
      thumbfast # thumbnails when hovering uosc's timeline
      autoload
      #modernx
    ];
  };

  # the desktop pet's clips plugin cuts replays with ffmpeg / ffprobe
  home.packages = [ pkgs.ffmpeg ];
}
