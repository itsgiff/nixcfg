{ config, pkgs, ... }:

{
  # Install NFS client tools
  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

  # Enable NFS client service
  services.rpcbind.enable = true;

  # Define common mount points
  fileSystems = {
    "/mnt/backups" = {
      device = "10.10.1.50:/volume1/backups";
      fsType = "nfs";
      options = [ "nfsvers=4.1" "x-systemd.automount" "noauto" ];
    };
    
    "/mnt/data" = {
      device = "10.10.1.50:/volume1/data";
      fsType = "nfs";
      options = [ "nfsvers=4.1" "x-systemd.automount" "noauto" ];
    };
    
    "/mnt/docker" = {
      device = "10.10.1.50:/volume1/docker";
      fsType = "nfs";
      options = [ "nfsvers=4.1" "x-systemd.automount" "noauto" ];
    };
    
    "/mnt/downloads" = {
      device = "10.10.1.50:/volume1/downloads";
      fsType = "nfs";
      options = [ "nfsvers=4.1" "x-systemd.automount" "noauto" ];
    };

    "/mnt/files" = {
      device = "10.10.1.50:/volume1/files/Paul";
      fsType = "nfs";
      options = [ "nfsvers=4.1" "x-systemd.automount" "noauto" ];
    };

    "/mnt/tv" = {
      device = "10.10.1.50:/volume1/tv";
      fsType = "nfs";
      options = [ "nfsvers=4.1" "x-systemd.automount" "noauto" ];
    };
    
    "/mnt/movies" = {
      device = "10.10.1.50:/volume1/movies";
      fsType = "nfs";
      options = [ "nfsvers=4.1" "x-systemd.automount" "noauto" ];
    };
    
    "/mnt/music" = {
      device = "10.10.1.50:/volume1/music";
      fsType = "nfs";
      options = [ "nfsvers=4.1" "x-systemd.automount" "noauto" ];
    };
  };
}