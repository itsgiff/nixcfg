{ config, pkgs, lib, ... }:

{
  ########################################
  ## Docker + NVIDIA on NixOS (stable)
  ########################################

  # NVIDIA Container Toolkit drivers/hooks
  hardware.nvidia-container-toolkit.enable = true;

  # Make sure the runtime + libs are actually in the system profile
  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    libnvidia-container
    # optional: docker-compose v2 CLI, if you want the standalone too
    # docker-compose
  ];

  # Docker daemon
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    # Daemon config with a STABLE runtime path (not a GC'ed /nix/store hash)
    daemon.settings = {
      default-runtime = "runc";
      runtimes = {};
    };
  };

  # Your user needs the right groups
  users.users.admin.extraGroups = [ "docker" "video" "render" ];

}
