{ config, pkgs, lib, ... }:

{
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    nvidia-docker
    libnvidia-container
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "/run/current-system/sw/bin/nvidia-docker";
          runtimeArgs = [];
        };
      };
    };
  };

  users.users.admin.extraGroups = [ "docker" "video" "render" ];
}