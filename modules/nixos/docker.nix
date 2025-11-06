{ config, pkgs, lib, ... }:

{
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    libnvidia-container
    podman
    podman-compose
  ];

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;  # This makes `docker` commands work with podman
  };

  users.users.admin.extraGroups = [ "podman" "video" "render" ];
}