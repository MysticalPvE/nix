# modules/system.nix
{ config, pkgs, ... }:

{
  # Set your time zone (e.g., "America/New_York", "Europe/Berlin")
  time.timeZone = "America/New_York"; # <-- CHANGE THIS TO YOUR TIMEZONE

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your system's hostname
  networking.hostName = "dhilipan"; # <-- CHANGE THIS IF YOU WISH

  # Nix settings, including enabling flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
