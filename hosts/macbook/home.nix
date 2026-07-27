{ config, pkgs, lib, ... }:

{
  # macOS-specific Home Manager configuration
  home.sessionVariables = {
    # Add any macOS-specific environment variables here
  };
  
  home.packages = with pkgs; [
   (python3.withPackages (ps: with ps; [
   garminconnect
   ]))
  ];
}