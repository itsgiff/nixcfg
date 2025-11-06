{ config, pkgs, lib, ... }:

{
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    nvidia-container-toolkit-tools
    libnvidia-container
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "nvidia-container-runtime";
          runtimeArgs = [];
        };
      };
    };
  };

  users.users.admin.extraGroups = [ "docker" "video" "render" ];
}