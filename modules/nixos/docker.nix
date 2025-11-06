{ config, pkgs, lib, ... }:

{
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    libnvidia-container
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      features = {
        cdi = true;
      };
    };
  };

  users.users.admin.extraGroups = [ "docker" "video" "render" ];

  systemd.services.setup-nvidia-cdi = {
    description = "Generate NVIDIA CDI specs";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /etc/cdi
      ${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
    '';
  };
}