# modules/graphics.nix
{ config, pkgs, pkgs-unstable, lib, ... }:

{
  # Graphics hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    # Use unstable Mesa packages
    package = pkgs-unstable.mesa;
    package32 = pkgs-unstable.pkgsi686Linux.mesa;

    # Extra packages for Intel graphics and VA-API
    extraPackages = with pkgs-unstable; [
      intel-gpu-tools
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      libva
      vulkan-loader
      vulkan-validation-layers
    ];

    # 32-bit support packages
    extraPackages32 = with pkgs-unstable; [
      intel-gpu-tools
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      libva
    ];
  };

  # Ensure Mesa is available in system packages
  environment.systemPackages = with pkgs-unstable; [
    mesa
  ];
}