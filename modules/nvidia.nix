# ~/.nixcfg/modules/nixos/nvidia.nix
{ config, pkgs, ... }:

{
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # NVIDIA driver configuration
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # Add NVIDIA kernel modules
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # Blacklist nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];
  
  # Enable OpenGL (required for GPU acceleration)
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # System utilities for GPU management
  environment.systemPackages = with pkgs; [
    pciutils
    glxinfo
  ];
}