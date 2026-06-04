{ config, pkgs, ... }:

{
  # X1-specific configuration
  home.sessionVariables = {
    # Add any X1-specific environment variables here
  };
  
  # X1-specific packages
  home.packages = with pkgs; [
    # Add X1-specific packages here
    publii
  ];
  
  # X1-specific settings
  # For example, override settings from modules with specific values for this machine
}