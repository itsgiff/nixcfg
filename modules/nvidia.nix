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
  
  # Use graphics instead of openGL (updated syntax)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  # Updated NVIDIA container toolkit setup
  virtualisation.docker = {
    enable = true;
  };
  
  # Use the newer NVIDIA container toolkit configuration
  virtualisation.podman.enableNvidia = true;
  # hardware.nvidia.container.enable = true;
 
  # NVIDIA Packages
  environment.systemPackages = [
    pkgs.cudatoolkit
    # pkgs.nvtop
    pkgs.pciutils
    pkgs.glxinfo
    pkgs.vulkan-tools
  ];
}