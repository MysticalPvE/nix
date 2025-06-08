# modules/audio.nix
{ config, pkgs, ... }:

{
  # Enable PipeWire for audio, which is the modern standard
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you have a Pro Audio setup, you can enable JACK support
    # jack.enable = true;
  };

  # IMPORTANT: Your udev rules grant permissions to the 'audio' group.
  # For low-latency audio and gaming, your user must be in these groups.
  # Add this to your main configuration or users.nix:
  #
  # users.users.dhilipan = {
  #   extraGroups = [ "wheel" "networkmanager" "audio" "realtime" ];
  # };
}