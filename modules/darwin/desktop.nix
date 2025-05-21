# ~/.nixcfg/modules/darwin/desktop.nix
# macOS desktop environment configuration
{ config, pkgs, lib, ... }:

{
  
  # Set environment variables
  environment.variables = {
    EDITOR = "nano";
    VISUAL = "code";
    LANG = "en_CA.UTF-8";
    HOMEBREW_NO_ANALYTICS = "1";
  };
  
  # macOS-specific packages
  environment.systemPackages = with pkgs; [
    # CLI tools
    #
    # Graphical tools
    #
  ];
  
}