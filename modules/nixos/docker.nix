# ~/.nixcfg/modules/nixos/docker.nix
{ config, pkgs, ... }:

{
  # Enable NVIDIA Container toolkit FIRST
  hardware.nvidia-container-toolkit.enable = true;

  # Enable Docker and related tools
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    
    # Configure Docker daemon with NVIDIA runtime
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-docker}/bin/nvidia-docker";
          runtimeArgs = [];
        };
      };
      # Set nvidia as the default runtime for all containers
      default-runtime = "nvidia";
    };
    
    # Docker cleanup settings
    autoPrune = {
      enable = false;
      dates = "weekly";
    };
  };

  # Ensure Docker packages are available
  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
    nvidia-docker
  ];
  
  # Ensure NVIDIA container toolkit systemd integration
  systemd.services.docker = {
    serviceConfig = {
      ExecStartPost = "${pkgs.coreutils}/bin/sleep 2";
    };
  };
  
  # Create Docker networks using systemd
  systemd.services.docker-networks = {
    description = "Create Docker networks";
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "docker-networks.sh" ''
        # Wait for docker socket to be available
        for i in {1..30}; do
          if [ -S /var/run/docker.sock ]; then
            break
          fi
          ${pkgs.coreutils}/bin/sleep 1
        done
        
        # Check if the proxy network exists
        if ! ${pkgs.docker}/bin/docker network ls | ${pkgs.gnugrep}/bin/grep -q proxy; then
          ${pkgs.docker}/bin/docker network create proxy
        fi
      '';
    };
  };
}
