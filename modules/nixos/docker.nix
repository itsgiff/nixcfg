# ~/.nixcfg/modules/nixos/docker.nix
{ config, pkgs, ... }:

{
  # Enable Docker and related tools
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # Enable NVIDIA runtime - this is the deprecated method and a temp fix - see below
    enableNvidia = true;    
    # Docker cleanup settings
    autoPrune = {
      enable = false;
      dates = "weekly";
    };
  };

  # Enable NVIDIA Container toolkit - this is the new method but it's not working yet - might be something with compose setup
  # hardware.nvidia-container-toolkit.enable = true;

  # Ensure Docker packages are available
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
        # Check if the proxy network exists
        if ! ${pkgs.docker}/bin/docker network ls | ${pkgs.gnugrep}/bin/grep -q proxy; then
          ${pkgs.docker}/bin/docker network create proxy
        fi
      '';
    };
  };
}