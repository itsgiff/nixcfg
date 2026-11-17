{ config, pkgs, lib, ... }:

{
  # GNOME settings (dconf) live in their own file
  imports = [ ./gnome.nix ];

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

  # ChatGPT: same Chrome --app approach as Notion and Perplexity. (OpenAI's
  # Linux app is only packaged in nixos-unstable, which this flake doesn't use.)
  xdg.desktopEntries.chatgpt = {
    name = "ChatGPT";
    genericName = "AI assistant";
    comment = "ChatGPT in a Chrome app window";
    # OpenAI knot in white on a clear background (from @lobehub/icons, MIT)
    icon = "${./icons/chatgpt.svg}";
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=https://chatgpt.com";
    categories = [ "Network" ];
    terminal = false;
    # Own dock icon instead of grouping under Chrome (same scheme as Notion;
    # no www. here because the --app URL has none)
    settings.StartupWMClass = "chrome-chatgpt.com__-Default";
  };
  
  # Files (Nautilus) sidebar bookmarks: the NFS shares from the Synology
  # (modules/nixos/nfs.nix) and Downloads. Add bookmarks here, not in Files:
  # Files would replace the link, and the next switch would move its file
  # aside to bookmarks.hm-bak.
  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///mnt/backups backups
    file:///mnt/files/Google%20Drive Google Drive
    file:///home/paul/Downloads Downloads
    file:///mnt/data data
    file:///mnt/docker docker
    file:///mnt/files files
  '';

  # X1-specific settings
  # For example, override settings from modules with specific values for this machine
}