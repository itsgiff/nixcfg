{ config, pkgs, lib, ... }:

{
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    libnvidia-container
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  users.users.admin.extraGroups = [ "docker" "video" "render" ];
}