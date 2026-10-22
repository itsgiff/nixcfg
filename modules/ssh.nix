# ~/.nixcfg/modules/ssh.nix
# SSH *client* config (Home Manager): the hosts these laptops connect to.
# Writes ~/.ssh/config on x1 and macbook. Does not run an SSH server.
{ config, pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;

    # Opt out of Home Manager's legacy defaults (and its deprecation warning)
    enableDefaultConfig = false;

    # Unmanaged, per-machine hosts can live in ~/.ssh/config.local
    includes = [ "config.local" ];

    settings = {
      udm = {
        HostName = "10.10.1.1";
        User = "root";
        IdentityFile = "~/.ssh/admin/admin_udm_ed25519";
        IdentitiesOnly = true;
        Port = 22;
      };

      homeassistant = {
        HostName = "10.10.1.40";
        User = "hassio";
        IdentityFile = "~/.ssh/infra/infra_homeassistant_ed25519";
        IdentitiesOnly = true;
        Port = 22;
      };

      jumpbox = {
        HostName = "10.10.1.50";
        User = "admin";
        IdentityFile = "~/.ssh/infra/infra_jumpbox_ed25519";
        IdentitiesOnly = true;
        Port = 2424;
      };

      media = {
        HostName = "10.10.1.60";
        User = "admin";
        IdentityFile = "~/.ssh/infra/infra_media_ed25519";
        IdentitiesOnly = true;
        Port = 22;
      };

      ai = {
        HostName = "10.10.1.70";
        User = "op";
        IdentityFile = "~/.ssh/infra/infra_ai_ed25519";
        IdentitiesOnly = true;
        Port = 22;
      };

      pi = {
        HostName = "10.10.1.80";
        User = "admin";
        IdentityFile = "~/.ssh/infra/infra_pi_ed25519";
        IdentitiesOnly = true;
        Port = 22;
      };

      gitea = {
        HostName = "10.10.1.50";
        User = "git";
        IdentityFile = "~/.ssh/infra/infra_gitea_ed25519";
        IdentitiesOnly = true;
        Port = 222;
        # Key must be added manually in the Gitea web UI (signature verification)
      };

      storage = {
        HostName = "10.10.1.50";
        User = "storageadmin";
        IdentityFile = "~/.ssh/infra/infra_storage_ed25519";
        IdentitiesOnly = true;
        Port = 2222;
      };

      # Public services
      "github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/services/services_github_ed25519";
        IdentitiesOnly = true;
      };
    };
  };
}
