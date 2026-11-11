{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    initContent = ''
      compressImage () {
        magick $1 -strip -resize 1920x1080 -quality 85% compressed.jpg
      }
      function y() {
      	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      	yazi "$@" --cwd-file="$tmp"
      	IFS= read -r -d ''\'' cwd < "$tmp"
      	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
      	rm -f -- "$tmp"
      }

      nixdev() {                                                             
        if [ -z "$1" ]; then
          echo "Usage: nixdev <package-name>"
          return 1    
        fi

        local package="$1"
        local target_dir="''${package}-src"

        if [ -d "$target_dir" ]; then
          echo "Source directory ''${target_dir} already exists, skipping copy..."
        else
          echo "Fetching source for nixpkgs#''${package}..."
          local src_path=$(nix build "nixpkgs#''${package}.src" --no-link --print-out-paths 2>/dev/null)

          if [ $? -ne 0 ]; then
            echo "Error: Failed to fetch source for ''${package}"
            return 1
          fi

          echo "Copying source to ''${target_dir}..."
          cp -r "$src_path" "$target_dir"
          chmod -R u+w "$target_dir"
        fi

        echo "Entering dev environment..."
        cd "$target_dir"
        nix develop "nixpkgs#''${package}"
      }

      # Build a host into the HDD chroot store and copy only what the SSD is missing,
      # leaving the result in $_HDD_OUT. Build-time-only paths never touch the NVMe.
      # Shared by nixSwitchHdd and nhSwitchHdd. See docs/hdd-store.md.
      _hddBuildAndCopy() {
        local store="''${NIX_HDD_STORE:-/data/nix-store}"
        local flake="''${1:-$HOME/projects/github/nix-config}"
        local host="''${2:-$(hostname)}"
        _HDD_OUT=""

        # /data is mounted nofail: without this guard a missing HDD silently builds
        # a fresh store onto the root filesystem.
        if ! mountpoint -q /data; then
          echo "/data is not mounted - refusing to build onto the SSD" >&2
          return 1
        fi

        echo "Building ''${host} into ''${store}..."
        local out
        out=$(nix build --store "$store" \
          "''${flake}#nixosConfigurations.''${host}.config.system.build.toplevel" \
          --no-link --print-out-paths) || return 1

        # Pipe the closure in over stdin so root never *opens* the HDD store. Root
        # opening it makes nix reinitialise the store dir as root-owned 1775, after
        # which every unprivileged build dies with
        #   opening lock file '...drv.lock': Permission denied
        # nix-store --import also accepts unsigned paths, which nix copy refuses even
        # under sudo (trusted users may override require-sigs, but it stays on).
        echo "Copying runtime closure to the SSD store..."
        local -a all missing
        local p
        all=(''${(f)"$(nix-store --store "$store" -qR "$out")"})

        # Ship only what the SSD lacks. Unlike nix copy, --export serialises whatever
        # it is handed, so exporting the whole closure re-reads tens of GB off the HDD
        # on every run even when nothing changed. Querying the daemon store is a read,
        # so it needs no sudo and does not touch the HDD store.
        local -A want
        for p in ''${(f)"$(nix-store --check-validity --print-invalid "''${all[@]}" 2>/dev/null)"}; do
          want[$p]=1
        done

        # Re-filter through `all` so topological order survives; --import needs each
        # path's references to already exist or appear earlier in the stream.
        for p in "''${all[@]}"; do
          [[ -n "''${want[$p]-}" ]] && missing+=("$p")
        done

        if (( ''${#missing} )); then
          echo "  transferring ''${#missing} of ''${#all} paths..."
          nix-store --store "$store" --export "''${missing[@]}" \
            | sudo nix-store --import >/dev/null || return 1
        else
          echo "  already present on the SSD, nothing to copy"
        fi

        _HDD_OUT="$out"
      }

      nixSwitchHdd() {
        _hddBuildAndCopy "$@" || return 1
        echo "Activating ''${_HDD_OUT}..."
        sudo nix-env -p /nix/var/nix/profiles/system --set "$_HDD_OUT" || return 1
        sudo "$_HDD_OUT/bin/switch-to-configuration" switch
      }

      # Same build, but hand the finished path to nh for its diff and generation
      # handling. nh takes a bare store path as an installable, so it resolves
      # instantly rather than rebuilding.
      # nh deliberately does NOT get NIX_REMOTE here: it has no cross-store copy
      # step, so it would build on the HDD and then try to activate a path the SSD
      # does not have. Building first and pointing nh at the copied path avoids that.
      nhSwitchHdd() {
        _hddBuildAndCopy "$@" || return 1
        nh os switch "$_HDD_OUT"
      }
      nhBootHdd() {
        _hddBuildAndCopy "$@" || return 1
        nh os boot "$_HDD_OUT"
      }
    '';
    history = {
      size = 100000;
      save = 100000;
    };
    shellAliases = {
      # TODO: gifsicle -O3 --lossy=30 noita-20240328-191617-1612416266-00316616.gif -o noita-20240328-191617-1612416266.gif
      backupNoita = "cp -r ~/.local/share/Steam/steamapps/compatdata/881100/pfx/drive_c/users/steamuser/AppData/LocalLow/Nolla_Games_Noita/* ~/synced/default/dont_remotebackup/noita_save";
      checkTime = "(cd ~/synced/work_drive/TS && nix run)";
      checkWaylandWindowsKDE = "qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole";
      collectGarbage = "nh clean all";
      edit = "cd ~/projects/github/nix-config && nvim .";
      # Build other hosts on the HDD instead of the SSD - see docs/hdd-store.md.
      buildHdd = "nix build --store /data/nix-store";
      # deploy-rs cannot use the HDD store at all - it stat()s the activation
      # symlinks, which dangle outside the chroot. See docs/hdd-store.md.
      # Usage: deployRebuildHdd root@192.168.0.20 --flake .#amd-server
      deployRebuildHdd = "NIX_REMOTE=/data/nix-store nixos-rebuild switch --target-host";
      deployBootHdd = "NIX_REMOTE=/data/nix-store nixos-rebuild boot --target-host";
      gcHdd = "nix store gc --store /data/nix-store";
      optimiseHdd = "nix store optimise --store /data/nix-store";
      ll = "ls -l";
      ls = "${pkgs.eza}/bin/eza --icons auto";
      la = "${pkgs.eza}/bin/eza -la --icons auto --group-directories-first";
      ssh = "TERM=xterm-256color ssh";
      update = "sudo nixos-rebuild switch";
      updateFancy = "nh os switch";
      updateOffline = "sudo nixos-rebuild switch --option substitute false";
      goto = ''
        cd $((
          find -L ~/projects -maxdepth 2 -type d
          find -L ~/projects/github/third-party/ -maxdepth 1 -type d
        ) | ${pkgs.fzf}/bin/fzf)'';
      dev = "nix-shell --run zsh";
      rmt = "trash put";
      bat = "bat -P --style plain";
      cdf = "cd $(fd --type d --exclude node_modules --exclude bin --exclude target --exclude .cache . | fzf)";
      cpu_performance = "echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";
      cpu_powersave = "echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";
      cpu_schedutil = "echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";
      cpu_freq = ''watch -n 1 "cat /proc/cpuinfo | grep \"^[c]pu MHz\""'';
      gpu_monitor = "nvidia-smi dmon -s puct";
      nix-shell = "nix-shell --command zsh";
      drag = "ripdrag";
      notes = "cd ~/synced/default/vimwiki && nvim index.md";
      zed = "zeditor";
    };
    #plugins = with pkgs; [
    #  {
    #    name = "powerlevel10k";
    #    src = "${zsh-powerlevel10k}/share/zsh-powerlevel10k";
    #    file = "powerlevel10k.zsh-theme";
    #  }
    #  {
    #    name = "powerlevel10k-config";
    #    src = ./.;
    #    file = ".p10k.zsh";
    #  }
    #];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "eastwood";
    };
  };
}
