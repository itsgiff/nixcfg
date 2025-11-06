{ config, pkgs, lib, ... }:

{
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    libnvidia-container
    podman
  ];

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
  };

  users.users.admin.extraGroups = [ "podman" "video" "render" ];
}