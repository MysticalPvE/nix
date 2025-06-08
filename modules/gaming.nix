# modules/gaming.nix
{ config, pkgs, pkgs-unstable, lib, ... }:

{
  # Steam configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    gamescopeSession.enable = true;
  };

  # Gamescope configuration
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Steam hardware support
  hardware.steam-hardware.enable = true;

  # Gaming packages
  environment.systemPackages = with pkgs-unstable; [
    # Lutris with additional libraries
    (lutris.override {
      extraLibraries = p: [ p.libadwaita p.gtk4 ];
    })

    # Gaming utilities
    glxinfo # Hardware information
    heroic # Native GOG, Epic, and Amazon Games Launcher
    ludusavi # Backup tool for PC game saves
    mangohud # Performance overlay

    # Wine and related
    wineWowPackages.staging # Wine with staging patches
    winetricks # Wine DLL installer script
  ];

  # Enable kernel modules for gaming hardware
  boot.kernelModules = [ "hid-tmff2" ];
}