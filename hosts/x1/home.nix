{ config, pkgs, lib, inputs, ... }:

let
  # Same derivation the system installs (configuration.nix), read for its version
  yogurt = pkgs.callPackage ./yogurt.nix { };

  # ChatGPT's own app icon, taken from the official OpenAI .deb that the
  # codex-desktop input repackages (that package swaps in a community icon).
  # Same url, name and hash as the input's fetch, so it is the .deb already
  # in the store and follows the input on every flake update.
  chatgptPins = builtins.fromJSON
    (builtins.readFile "${inputs.codex-desktop}/nix/upstream-linux-packages.json");
  chatgptDeb = pkgs.fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/${chatgptPins.amd64.repositoryPath}";
    hash = chatgptPins.amd64.sri;
    name = "chatgpt_${chatgptPins.version}_amd64.deb";
  };
  chatgptIcon = pkgs.runCommand "chatgpt.png" { nativeBuildInputs = [ pkgs.dpkg ]; } ''
    # Unpack only the PNGs: a full `dpkg-deb -x` fails in the build sandbox,
    # which refuses the setuid bit on Electron's chrome-sandbox
    mkdir root
    dpkg-deb --fsys-tarfile ${chatgptDeb} \
      | tar -x -C root --no-same-owner --no-same-permissions --wildcards '*.png'
    # Largest hicolor app icon, else the Electron window icon
    # `|| true`: the builder runs with errexit and pipefail, so a find with no
    # match (or no usr/share/icons) would otherwise end the build silently
    icon=$(find root/usr/share/icons -path '*/apps/*.png' 2>/dev/null | sort -V | tail -n1 || true)
    [ -n "$icon" ] || icon=$(find root -name icon-chatgpt.png | head -n1 || true)
    if [ -z "$icon" ]; then
      echo "No ChatGPT icon found in the .deb. PNG candidates:" >&2
      find root -name '*.png' | grep -i -e icon -e chatgpt -e openai >&2 || true
      exit 1
    fi
    echo "Using $icon"
    cp "$icon" $out
  '';

  # The input's package with its launcher renamed from "ChatGPT Community" to
  # "ChatGPT" and given the real icon, like the Mac app. Wraps the same build
  # the module installs by default, so nothing is rebuilt.
  chatgptDesktop = pkgs.symlinkJoin {
    name = "codex-desktop-chatgpt-branding";
    paths = [ inputs.codex-desktop.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop ];
    postBuild = ''
      desktopFile="$out/share/applications/codex-desktop.desktop"
      target="$(readlink -f "$desktopFile")"
      rm -f "$desktopFile"
      substitute "$target" "$desktopFile" \
        --replace-fail "Name=ChatGPT Community" "Name=ChatGPT" \
        --replace-fail "Icon=codex-desktop" "Icon=${chatgptIcon}"
    '';
  };

  yogurt-update-check = pkgs.writeShellApplication {
    name = "yogurt-update-check";
    runtimeInputs = with pkgs; [ coreutils curl jq libnotify ];
    text = ''
      installed="''${1:-${yogurt.version}}"
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/yogurt-update-check"

      # Offline or rate-limited: try again next week
      latest=$(curl -fsSL --max-time 20 \
        https://api.github.com/repos/FrigadeHQ/yogurt/releases/latest \
        | jq -r '.tag_name // empty') || exit 0
      latest="''${latest#v}"
      [ -n "$latest" ] || exit 0

      if [ "$latest" = "$installed" ]; then
        echo "Yogurt $installed is the latest release"
        exit 0
      fi
      # Already told about this version
      if [ -f "$state" ] && [ "$(cat "$state")" = "$latest" ]; then
        echo "Yogurt $latest is out (already notified)"
        exit 0
      fi

      notify-send --app-name=Yogurt --icon=yogurt \
        "Yogurt $latest is out" \
        "nixcfg has $installed. Bump version and hash in hosts/x1/yogurt.nix."
      echo "Yogurt $latest is out; nixcfg has $installed"
      mkdir -p "$(dirname "$state")"
      echo "$latest" > "$state"
    '';
  };
in
{
  # GNOME settings (dconf) live in their own file
  imports = [
    ./gnome.nix
    inputs.codex-desktop.homeManagerModules.default
  ];

  # ChatGPT desktop app with Codex (ilysenko/codex-desktop-linux, from OpenAI's
  # official Linux .deb; command and launcher: codex-desktop). Shares
  # ~/.codex with Codex skills from modules/ai/skills.nix. Shown as "ChatGPT"
  # with OpenAI's icon (chatgptDesktop above).
  programs.codexDesktopLinux = {
    enable = true;
    package = chatgptDesktop;
  };

  # X1-specific configuration
  home.sessionVariables = {
    # Add any X1-specific environment variables here
  };
  
  # X1-specific packages
  home.packages = with pkgs; [
    # Add X1-specific packages here
    yogurt-update-check   # also runnable by hand; pass a version to test, e.g. 0.0.0
  ];

  # Yogurt is a pinned AppImage (yogurt.nix), so fullUpdate never updates it.
  # Once a week, compare the packaged version with GitHub's latest release and
  # send a GNOME notification, once per new version. Run it now with
  # `systemctl --user start yogurt-update-check`.
  systemd.user.services.yogurt-update-check = {
    Unit.Description = "Check GitHub for a newer Yogurt release";
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe yogurt-update-check;
    };
  };
  systemd.user.timers.yogurt-update-check = {
    Unit.Description = "Weekly check for a newer Yogurt release";
    Timer = {
      OnCalendar = "Mon *-*-* 10:00:00";   # Monday mornings
      Persistent = true;   # missed while asleep or off: run at next login
      RandomizedDelaySec = "1h";
    };
    Install.WantedBy = [ "timers.target" ];
  };

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

  # Claude Code sign-in links (claude-cli://). Claude Code writes its own
  # claude-code-url-handler.desktop pointing at whichever store path first ran
  # it, which breaks once garbage collection removes that version. This one is
  # rebuilt on every switch, so it always points at the installed Claude Code.
  xdg.desktopEntries.claude-cli-url-handler = {
    name = "Claude Code URL Handler";
    exec = "${config.programs.claude-code.package}/bin/claude --handle-uri %u";
    terminal = false;
    noDisplay = true;
    mimeType = [ "x-scheme-handler/claude-cli" ];
  };

  # WhatsApp: same Chrome --app approach as Notion and Perplexity
  # (replaces the Chrome "Install as app" launcher, which nixcfg didn't declare).
  # Icon: simple-icons logo in the brand colour, like Perplexity's.
  xdg.desktopEntries.whatsapp = {
    name = "WhatsApp";
    genericName = "Messaging";
    comment = "WhatsApp Web in a Chrome app window";
    icon = "${./icons/whatsapp.svg}";
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=https://web.whatsapp.com";
    categories = [ "Network" "InstantMessaging" ];
    terminal = false;
    # Own dock icon instead of grouping under Chrome (same scheme as Notion)
    settings.StartupWMClass = "chrome-web.whatsapp.com__-Default";
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

  # Default apps (~/.config/mimeapps.list). GNOME Settings > Default Apps and
  # "always open with" can't change these any more; change them here.
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        chrome = "google-chrome.desktop";
        vscode = "code.desktop";
        thunderbird = "thunderbird.desktop";
      in
      {
        # Web
        "x-scheme-handler/http" = chrome;
        "x-scheme-handler/https" = chrome;
        "x-scheme-handler/about" = chrome;
        "x-scheme-handler/unknown" = chrome;
        "text/html" = chrome;
        "application/xhtml+xml" = chrome;
        # Text, scripts and unknown files open in VS Code
        "text/plain" = vscode;
        "application/x-yaml" = vscode;
        "application/x-shellscript" = vscode;
        "application/octet-stream" = vscode;
        "application/x-zerosize" = vscode;
        # Documents and images
        "application/pdf" = "org.gnome.Papers.desktop";
        "image/png" = "feh.desktop";
        # Mail
        "x-scheme-handler/mailto" = thunderbird;
        "x-scheme-handler/mid" = thunderbird;
        "x-scheme-handler/net.thunderbird" = thunderbird;
        "message/rfc822" = thunderbird;
        # Signal links and Claude Code sign-in links
        "x-scheme-handler/sgnl" = "signal.desktop";
        "x-scheme-handler/signalcaptcha" = "signal.desktop";
        "x-scheme-handler/claude-cli" = "claude-cli-url-handler.desktop";
      };
  };

  # X1-specific settings
  # For example, override settings from modules with specific values for this machine
}