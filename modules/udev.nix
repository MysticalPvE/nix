# modules/udev-rules.nix
{ config, pkgs, lib, ... }:

{
  # Custom udev rules for power management and hardware optimization
  services.udev.extraRules = ''
    # Audio power management based on AC power status
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", TEST=="/sys/module/snd_hda_intel", \
        RUN+="${pkgs.bash}/bin/sh -c 'echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"

    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", TEST=="/sys/module/snd_hda_intel", \
        RUN+="${pkgs.bash}/bin/sh -c 'echo 10 > /sys/module/snd_hda_intel/parameters/power_save'"

    # ZRAM and swap optimization
    ACTION=="change", KERNEL=="zram0", ATTR{initstate}=="1", SYSCTL{vm.swappiness}="150", \
        RUN+="${pkgs.bash}/bin/sh -c 'echo N > /sys/module/zswap/parameters/enabled'"

    # RTC and HPET permissions for audio group
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"

    # NVMe scheduler optimization (set to none for SSDs)
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
        ATTR{queue/scheduler}="none"

    # HDD power management with hdparm
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", \
        RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 /dev/%k"

    # CPU DMA latency permissions for audio group
    DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
  '';

  # Ensure required packages are available
  environment.systemPackages = with pkgs; [
    hdparm  # For HDD power management
  ];
}