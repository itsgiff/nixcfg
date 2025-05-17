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
    # Use the stable driver package
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # DO NOT add these to boot.initrd.kernelModules, add them to boot.kernelModules instead
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  
  # Blacklist nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  virtualisation.docker.enableNvidia = true;
  
  # NVIDIA Packages
  environment.systemPackages = with pkgs; [
    cudatoolkit
    pciutils
    glxinfo
  ];
}