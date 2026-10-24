{ config, pkgs, lib, ... }:

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
    # Without this the entry has no Icon= line and GNOME shows its generic
    # fallback. The ${} path copies the PNG into the Nix store.
    icon = "${./icons/notion.png}";
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=https://www.notion.so";
    categories = [ "Office" ];
    terminal = false;
    # Must match the window's app ID (Looking Glass → Windows → wmclass) so
    # GNOME shows Notion as its own dock icon instead of grouping it under Chrome
    settings.StartupWMClass = "chrome-www.notion.so__-Default";
  };

  # Perplexity has no Linux desktop app (and nothing in nixpkgs), so the same
  # Chrome --app approach as Notion. Icon: simple-icons logo in the brand colour.
  xdg.desktopEntries.perplexity = {
    name = "Perplexity";
    genericName = "AI answer engine";
    comment = "Perplexity in a Chrome app window";
    icon = "${./icons/perplexity.svg}";
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=https://www.perplexity.ai";
    categories = [ "Network" ];
    terminal = false;
    # Own dock icon instead of grouping under Chrome (same scheme as Notion)
    settings.StartupWMClass = "chrome-www.perplexity.ai__-Default";
  };
  
  # Screen blank, lock and idle suspend (GNOME). Values match what was set
  # in GNOME Settings on 2026-10-24, so the first switch changes nothing.
  # uint32 keys need mkUint32; dconf rejects a plain int for them.
  dconf.settings = {
    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 900; # blank after 15 min
    };
    "org/gnome/desktop/screensaver" = {
      lock-enabled = true; # lock when the screen blanks (GNOME default)
      lock-delay = lib.hm.gvariant.mkUint32 0; # lock immediately (GNOME default)
    };
    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = false;
      power-saver-profile-on-low-battery = false;
      # Never suspend on idle; the timeouts only matter if a type is changed
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-ac-timeout = 7200;
      sleep-inactive-battery-type = "nothing";
      sleep-inactive-battery-timeout = 3600;
    };
  };

  # X1-specific settings
  # For example, override settings from modules with specific values for this machine
}