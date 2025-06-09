# modules/boot.nix
{ config, pkgs, lib, ... }:

{
  boot = {
    # Use CachyOS kernel for better performance
    kernelPackages = pkgs.linuxPackages_cachyos;

    # Clean /tmp on boot
    tmp.cleanOnBoot = true;

    # Force disable ZFS
    supportedFilesystems.zfs = lib.mkForce false;

    # Kernel parameters based on CPU type
    kernelParams =
      if builtins.elem "kvm-amd" config.boot.kernelModules
      then [ "amd_pstate=active" "nosplit_lock_mitigate" ]
      else [ "nosplit_lock_mitigate" ];
  };

  # Kernel sysctl parameters for performance optimization
  boot.kernel.sysctl = {
    # Memory management
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456;
    "vm.page-cluster" = 0;
    "vm.dirty_background_bytes" = 67108864;
    "vm.dirty_writeback_centisecs" = 1500;

    # Kernel security and performance
    "kernel.nmi_watchdog" = 0;
    "kernel.unprivileged_userns_clone" = 1;
    "kernel.printk" = "3 3 3 3";
    "kernel.kptr_restrict" = 2;
    "kernel.kexec_load_disabled" = 1;

    # Network performance (merged from system-tweaks)
    # "net.core.netdev_max_backlog" = 4096;

    # File system (merged from system-tweaks)
    # "fs.file-max" = 2097152;
  };

  # ZRAM swap configuration - Updated to match your Arch config
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;  # Use full RAM size like your Arch config
    priority = 100;       # Higher priority like your Arch config
  };
}
