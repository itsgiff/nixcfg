# ~/.nixcfg/modules/nixos/docker.nix
{ config, pkgs, ... }:

{
  # Enable NVIDIA container toolkit
  hardware.nvidia-container-toolkit.enable = true;

  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    
    # Register NVIDIA runtime with Docker daemon
    daemon.settings = {
      default-runtime = "runc";
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
          runtimeArgs = [ ];
        };
      };
    };
    
    # Docker cleanup settings
    autoPrune = {
      enable = false;
      dates = "weekly";
    };
  };

  # Docker tools and NVIDIA container packages
  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
    nvidia-container-toolkit
    nvidia-docker
  ];
  
  # Create Docker proxy network on startup
  systemd.services.docker-networks = {
    description = "Create Docker networks";
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "docker-networks.sh" ''
        set -e
        # Wait for docker socket
        for i in {1..30}; do
          if [ -S /var/run/docker.sock ]; then
            break
          fi
          sleep 1
        done
        
        # Create proxy network if it doesn't exist
        if ! ${pkgs.docker}/bin/docker network ls | ${pkgs.gnugrep}/bin/grep -q "proxy"; then
          ${pkgs.docker}/bin/docker network create proxy
        fi
      '';
    };
  };
}