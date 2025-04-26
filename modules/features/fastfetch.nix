{ config, pkgs, lib, ... }:

{
  # Configure fastfetch with your custom settings
  xdg.configFile."fastfetch/config.jsonc" = {
    text = ''
      // Inspired by Catnap
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
            "type": "small"
        },
        "display": {
            "separator": "",
            "key": {
                "width": 15
            }
        },
        "modules": [
            {
                "key": "os",
                "type": "os",
                "format": "{3}"
            },
            {
                "key": "cpu",
                "type": "cpu",
                "showPeCoreCount": true
            },
            {
                "key": "gpu",
                "type": "gpu"
            },           
            {
                "key": "disk",
                "type": "disk",
                "folders": "/"
            },
            {
                "key": "memory",
                "type": "memory"
            },
            {
                "key": "battery",
                "type":  "battery"
            }
        ]
      }
    '';
  };
}