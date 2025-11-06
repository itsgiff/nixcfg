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
    nvidia-container-runtime
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
      default-runtime = "nvidia";
      runtimes = {
        nvidia = {
          path = "/run/current-system/sw/bin/nvidia-container-runtime";
          "runtimeArgs" = [];
        };
      };

      # Optional: keep logs sane
      log-driver = "json-file";
      log-opts = {
        "max-size" = "50m";
        "max-file" = "3";
      };
    };

    # Optional: adjust as you like
    # storageDriver = "overlay2";
    # enableNvidia = true;   # not required when we set runtimes above
  };

  # Your user needs the right groups
  users.users.admin.extraGroups = [ "docker" "video" "render" ];

  ########################################
  ## One-shot setup to ensure Docker hooks + CDI exist
  ########################################
  systemd.services."nvidia-container-toolkit-setup" = {
    description = "Configure NVIDIA Container Toolkit runtime and generate CDI spec";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -e
      # Wire the Docker runtime hook (safe to re-run)
      ${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk runtime configure --runtime=docker

      # Generate CDI so `--gpus` works without legacy runtime
      mkdir -p /etc/cdi
      ${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

      # Restart Docker to pick up changes
      systemctl restart docker
    '';
  };
}
