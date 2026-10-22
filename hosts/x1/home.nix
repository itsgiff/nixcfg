{ config, pkgs, ... }:

{
  # X1-specific configuration
  home.sessionVariables = {
    # Add any X1-specific environment variables here
  };
  
  # X1-specific packages
  home.packages = with pkgs; [
    # Add X1-specific packages here
  ];

  # Notion has no official Linux desktop app, so run notion.so in a
  # Chrome app window (own window and launcher, no browser UI)
  xdg.desktopEntries.notion = {
    name = "Notion";
    genericName = "Notes and docs";
    comment = "Notion in a Chrome app window";
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=https://www.notion.so";
    categories = [ "Office" ];
    terminal = false;
  };
  
  # X1-specific settings
  # For example, override settings from modules with specific values for this machine
}