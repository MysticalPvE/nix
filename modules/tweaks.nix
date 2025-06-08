# modules/system-tweaks.nix
{ config, pkgs, lib, ... }:

{
  # Kernel module options and blacklisting
  boot.blacklistedKernelModules = [
    "iTCO_wdt"      # Intel TCO Watchdog/Timer
    "sp5100_tco"    # AMD SP5100 TCO Watchdog/Timer
  ];

  # Kernel module parameters
  boot.kernelModules = [ "amdgpu" ];
  boot.extraModprobeConfig = ''
    # Audio power save off
    options snd_hda_intel power_save=0

    # Force using of the amdgpu driver for Southern Islands (GCN 1.0+) and Sea Islands (GCN 2.x)
    options amdgpu si_support=1 cik_support=1
    options radeon si_support=0 cik_support=0
  '';

  # Additional sysctl parameters (extending your existing boot.nix)
  boot.kernel.sysctl = {
    # Network performance
    "net.core.netdev_max_backlog" = 4096;

    # File system
    "fs.file-max" = 2097152;

    # BORE Scheduler settings (uncommented as requested)
    "kernel.sched_burst_cache_lifetime" = 60000000;
    "kernel.sched_burst_fork_atavistic" = 2;
    "kernel.sched_burst_penalty_offset" = 22;
    "kernel.sched_burst_penalty_scale" = 1280;
    "kernel.sched_burst_smoothness_long" = 1;
    "kernel.sched_burst_smoothness_short" = 0;
    "kernel.sched_burst_exclude_kthreads" = 1;
  };

  # Systemd configuration
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=15s
    DefaultTimeoutStopSec=10s
    DefaultLimitNOFILE=2048:2097152
  '';

  # Journal configuration
  services.journald.extraConfig = ''
    SystemMaxUse=50M
  '';

  # Systemd service configuration - Fixed syntax
  systemd.services."getty@".serviceConfig = {
    LogLevelMax = "info";
  };

  # Systemd slice configuration for OOM management
  systemd.slices.system = {
    sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "80%";
    };
  };

  # Timesyncd configuration
  services.timesyncd = {
    enable = true;
    servers = [ "time.cloudflare.com" ];
    fallbackServers = [
      "time.google.com"
      "0.arch.pool.ntp.org"
      "1.arch.pool.ntp.org"
      "2.arch.pool.ntp.org"
      "3.arch.pool.ntp.org"
    ];
  };

  # NetworkManager configuration
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  services.resolved.enable = true;

  # Tmpfiles rules for system optimization
  systemd.tmpfiles.rules = [
    # Increase the highest requested RTC interrupt frequency
    "w! /sys/class/rtc/rtc0/max_user_freq - - - - 3072"
    "w! /proc/sys/dev/hpet/max-user-freq - - - - 3072"

    # THP Shrinker optimization (kernel 6.12+)
    "w! /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 409"

    # Clear old coredumps
    "d /var/lib/systemd/coredump 0755 root root 3d"

    # Improve performance for tcmalloc applications
    "w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
  ];

  # PCI latency timer service
  systemd.services.pci-latency = {
    description = "Adjust latency timers for PCI peripherals";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "pci-latency" ''
        # Check if the script is run with root privileges
        if [ "$(id -u)" -ne 0 ]; then
          echo "Error: This script must be run with root privileges." >&2
          exit 1
        fi

        # Reset the latency timer for all PCI devices
        ${pkgs.pciutils}/bin/setpci -v -s '*:*' latency_timer=20
        ${pkgs.pciutils}/bin/setpci -v -s '0:0' latency_timer=0

        # Set latency timer for all sound cards
        ${pkgs.pciutils}/bin/setpci -v -d "*:*:04xx" latency_timer=80
      ''}";
    };
  };

  # Game performance script and utilities
  environment.systemPackages = with pkgs; [
    pciutils
    power-profiles-daemon
    (writeShellScriptBin "game-performance" ''
      #!/usr/bin/env bash
      # Helper script to enable the performance gov with proton or others
      if ! command -v powerprofilesctl &>/dev/null; then
          echo "Error: powerprofilesctl not found" >&2
          exit 1
      fi

      # Don't fail if the CPU driver doesn't support performance power profile
      if ! powerprofilesctl list | grep -q 'performance:'; then
          exec "$@"
      fi

      # Set performance governors, as long the game is launched
      if [ -n "$GAME_PERFORMANCE_SCREENSAVER_ON" ]; then
          exec powerprofilesctl launch -p performance \
              -r "Launched with game-performance utility" -- "$@"
      else
          exec systemd-inhibit --why "game-performance is running" powerprofilesctl launch \
              -p performance -r "Launched with game-performance utility" -- "$@"
      fi
    '')

    # Zink Mesa wrapper script
    (writeShellScriptBin "zink-mesa" ''
      #!/usr/bin/env bash
      export MESA_LOADER_DRIVER_OVERRIDE=zink
      export GALLIUM_DRIVER=zink
      export __GLX_VENDOR_LIBRARY_NAME=mesa
      export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json
      exec "$@"
    '')
  ];

  # Enable power-profiles-daemon
  services.power-profiles-daemon.enable = true;
}