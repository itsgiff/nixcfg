# ~/.nixcfg/modules/nixos/docker.nix
{ config, pkgs, ... }:

{
  # Enable Docker and related tools
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # Additional Docker settings can go here
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
}