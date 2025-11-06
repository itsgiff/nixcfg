{ config, pkgs, lib, ... }:

let
  toolkit = pkgs.nvidia-container-toolkit;
in
{
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    toolkit
    libnvidia-container
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${toolkit}/bin/nvidia-container-runtime";
          runtimeArgs = [];
        };
      };
    };
  };

  users.users.admin.extraGroups = [ "docker" "video" "render" ];
}