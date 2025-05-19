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
    # Use the stable driver package without specifying a specific kernel package
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # Add NVIDIA kernel modules
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  
  # Blacklist nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];
  
  # Enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  
  # Enable NVIDIA Container toolkit
  hardware.nvidia-container-toolkit.enable = true;

  # NVIDIA Packages
  environment.systemPackages = with pkgs; [
    # cudatoolkit # Uncomment if needed for CUDA development
    pciutils
    glxinfo
  ];
}
