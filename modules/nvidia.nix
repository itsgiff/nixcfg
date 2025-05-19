# ~/.nixcfg/modules/nvidia.nix
{ config, pkgs, ... }:

{
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # NVIDIA driver configuration
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # Add NVIDIA kernel modules
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # Blacklist nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];
  
  # Enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # NVIDIA Packages
  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    nvidia-docker
    pciutils
    glxinfo
  ];
}
