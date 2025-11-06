{ config, pkgs, lib, ... }:

with lib;
let
  # Get the docker user(s) from configuration
  dockerUsers = builtins.attrNames config.users.users;
  # Filter to only users we want in docker group
  dockerGroupUsers = filter (u: u == "admin" || u == "paul") dockerUsers;
in
{
  ########################################
  ## Docker + NVIDIA on NixOS
  ########################################

  # Enable NVIDIA Container Toolkit support
  hardware.nvidia-container-toolkit.enable = true;

  # Docker daemon configuration with explicit NVIDIA runtime
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    
    # This creates /etc/docker/daemon.json with these settings
    daemon.settings = {
      default-runtime = "nvidia";
      
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
          runtimeArgs = [];
        };
      };

      # Logging configuration
      log-driver = "json-file";
      log-opts = {
        "max-size" = "50m";
        "max-file" = "3";
      };
    };
  };

  # Ensure all required packages are in system profile
  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    nvidia-container-runtime
    libnvidia-container
    docker-compose
  ];

  # Add docker and video groups to all docker-enabled users
  users.users = builtins.mapAttrs (name: user:
    if builtins.elem name dockerGroupUsers then
      {
        extraGroups = (user.extraGroups or []) ++ [ "docker" "video" "render" ];
      }
    else
      {}
  ) config.users.users;

  ########################################
  ## Setup service for NVIDIA Container integration
  ########################################
  systemd.services.nvidia-container-toolkit-setup = {
    description = "Configure NVIDIA Container Toolkit and generate CDI spec";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
    };
    
    script = ''
      set -e
      
      echo "=== Starting NVIDIA Container Toolkit setup ==="
      
      # Wait a moment for docker to be fully ready
      sleep 2
      
      # 1. Verify docker daemon.json exists and has nvidia runtime
      echo "Checking Docker daemon configuration..."
      if [ -f /etc/docker/daemon.json ]; then
        echo "  ✓ /etc/docker/daemon.json exists"
        ${pkgs.jq}/bin/jq '.runtimes.nvidia // "NOT FOUND"' /etc/docker/daemon.json || true
      else
        echo "  ✗ /etc/docker/daemon.json NOT FOUND (this is a problem!)"
        exit 1
      fi
      
      # 2. Generate CDI specification for --gpus support
      echo "Generating CDI specification..."
      mkdir -p /etc/cdi
      ${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi generate \
        --output=/etc/cdi/nvidia.yaml
      
      if [ -f /etc/cdi/nvidia.yaml ]; then
        echo "  ✓ CDI spec created at /etc/cdi/nvidia.yaml"
      else
        echo "  ✗ Failed to create CDI spec"
        exit 1
      fi
      
      # 3. Verify Docker can access the nvidia-container-runtime
      echo "Verifying nvidia-container-runtime is accessible..."
      if ${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime --version > /dev/null 2>&1; then
        echo "  ✓ nvidia-container-runtime is accessible"
        ${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime --version || true
      else
        echo "  ✗ nvidia-container-runtime not accessible"
        exit 1
      fi
      
      echo "=== NVIDIA Container Toolkit setup complete ==="
    '';
  };

  ########################################
  ## Verification service (manual)
  ########################################
  systemd.services.docker-nvidia-verify = {
    description = "Verify NVIDIA Docker setup";
    wantedBy = [];  # Manual only: systemctl start docker-nvidia-verify
    after = [ "nvidia-container-toolkit-setup.service" "docker.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "journal";
      StandardError = "journal";
    };
    
    script = ''
      echo "========================================="
      echo "  NVIDIA Docker Verification Report"
      echo "========================================="
      
      echo ""
      echo "1. NVIDIA Host Setup:"
      echo "   Command: nvidia-smi"
      nvidia-smi || echo "   ERROR: nvidia-smi failed"
      
      echo ""
      echo "2. Docker Daemon Configuration:"
      echo "   File: /etc/docker/daemon.json"
      if [ -f /etc/docker/daemon.json ]; then
        ${pkgs.jq}/bin/jq . /etc/docker/daemon.json || cat /etc/docker/daemon.json
      else
        echo "   ERROR: File not found!"
      fi
      
      echo ""
      echo "3. Docker Runtime Configuration:"
      docker info | grep -A 15 runtimes || echo "   Could not retrieve runtimes"
      
      echo ""
      echo "4. CDI Configuration:"
      if [ -f /etc/cdi/nvidia.yaml ]; then
        echo "   ✓ CDI spec exists"
        head -20 /etc/cdi/nvidia.yaml
        echo "   ... (truncated)"
      else
        echo "   ✗ CDI spec not found at /etc/cdi/nvidia.yaml"
      fi
      
      echo ""
      echo "5. Quick Docker-GPU Test:"
      echo "   Attempting: docker run --rm --gpus all ubuntu nvidia-smi"
      docker run --rm --gpus all ubuntu nvidia-smi 2>&1 | head -20 || echo "   Test failed - see above"
      
      echo ""
      echo "========================================="
    '';
  };
}
