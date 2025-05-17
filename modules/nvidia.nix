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
  
  # Ensure kernel modules are loaded
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  
  # Set kernel parameters for NVIDIA
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  
  # Use openGL
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };
  
  # Alternative NVIDIA Docker setup (for older NixOS versions)
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };
 
  # NVIDIA Packages
  environment.systemPackages = [
    pkgs.cudatoolkit
    # pkgs.nvtop
    pkgs.pciutils
    pkgs.glxinfo
    pkgs.vulkan-tools
  ];
}
