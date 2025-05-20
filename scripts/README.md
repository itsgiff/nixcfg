# NixCfg Init Script

This directory contains utility scripts for the nixcfg configuration.

## nixinit.sh

Bootstrap script to initialize a new machine with the nixcfg configuration.

### Usage on a fresh NixOS installation:
```bash
wget -O- https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash
```

### If curl is available (e.g., on macOS):
```bash
curl -L https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash
```

### Features:

- Validates hostname (must be one of: x1, nuc, macbook)
- Backs up original NixOS configuration files
- Ensures git is installed on NixOS systems
- Clones the nixcfg repository and sets up the gitea remote
- Enables nix flake experimental features
- Applies the flake configuration for the specified host
- Provides specialized handling for macOS
- Sets up Docker environment for NUC host
- Optionally installs fish shell enhancements

### Security Note:

For additional security, you can download the script first to inspect it before running:

```bash
# Download the script
wget https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh
# Review it
less nixinit.sh
# Make it executable
chmod +x nixinit.sh
# Run it
./nixinit.sh
```