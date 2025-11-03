# ~/.nixcfg/modules/nixos/docker.nix
{ config, pkgs, ... }:

{
  # Enable NVIDIA container toolkit - this is the modern, officially supported way
  hardware.nvidia-container-toolkit.enable = true;

  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    
    # Docker cleanup settings
    autoPrune = {
      enable = false;
      dates = "weekly";
    };
  };

  # Ensure Docker compose is available
  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
  ];
  
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
