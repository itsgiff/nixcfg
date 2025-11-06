{ config, pkgs, lib, ... }:

let
  nvidiaCTK = pkgs.nvidia-container-toolkit;
in
{
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    libnvidia-container
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${nvidiaCTK}/bin/nvidia-ctk";
          runtimeArgs = [ "runtime" "configure" "--runtime=docker" ];
        };
      };
    };
  };

  users.users.admin.extraGroups = [ "docker" "video" "render" ];
}