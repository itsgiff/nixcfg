# ~/.nixcfg/modules/ssh.nix
{ config, pkgs, ... }:

{ 

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
    };
  };

  # SSH connections
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      Host udm
          HostName 10.10.1.1
          User root
          IdentityFile ~/.ssh/admin/admin_udm_ed25519
          Port 22

      Host homeassistant
          HostName 10.10.1.40
          User hassio
          IdentityFile ~/.ssh/infra/infra_homeassistant_ed25519
          Port 22

      Host jumpbox
          HostName 10.10.1.50
          User admin
          IdentityFile ~/.ssh/infra/infra_jumpbox_ed25519
          Port 2424

      Host media
          HostName 10.10.1.60
          User admin
          IdentityFile ~/.ssh/infra/infra_media_ed25519
          Port 22

      Host pi
          HostName 10.10.1.80
          User admin
          IdentityFile ~/.ssh/infra/infra_pi_ed25519
          Port 22

      Host storage
          HostName 10.10.1.50
          User storageadmin
          IdentityFile ~/.ssh/infra/infra_storage_ed25519
          Port 2222
    '';
  };
}
