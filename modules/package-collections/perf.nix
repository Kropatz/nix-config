{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    perf
    hotspot
    (writeShellScriptBin "start-recording" ''
      PID=$(pgrep $1)
      if [ -z "$PID" ]; then
        echo "Process $1 not found."
        exit 1
      fi
      sudo perf record -F 999 -p $PID -g
      sudo chown $USER:$(id -gn $USER) perf.data
    '')
  ];
}
