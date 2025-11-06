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
  };

  users.users.admin.extraGroups = [ "docker" "video" "render" ];

  # Configure NVIDIA Docker integration
  systemd.services.setup-nvidia-docker = {
    description = "Setup NVIDIA Docker runtime";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk runtime configure --runtime=docker
      systemctl restart docker
    '';
  };
}