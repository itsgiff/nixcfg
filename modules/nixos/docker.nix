# ~/.nixcfg/modules/nixos/docker.nix
{ config, pkgs, ... }:

{
  # Enable NVIDIA Container toolkit first (this must come before Docker config)
  hardware.nvidia-container-toolkit.enable = true;

  # Enable Docker and related tools
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # Configure NVIDIA as the default runtime
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-docker}/bin/nvidia-docker";
          runtimeArgs = [];
        };
      };
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
