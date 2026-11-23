# ~/.nixcfg/hosts/x1/gnome.nix
# GNOME settings for the x1, written to dconf by Home Manager on every switch.
# A setting changed by hand in GNOME is put back to these values on the next
# switch; a key removed from here is reset to GNOME's default.
# To find what a toggle writes: run `dconf watch /`, change it, read the key.
# uint32 keys need mkUint32; dconf rejects a plain int for them.
{ lib, ... }:

let
  inherit (lib.hm.gvariant) mkUint32 mkVariant mkTuple mkEmptyArray type;

  # Wallpaper for the desktop and the lock screen. The ${} path copies the
  # JPEG into the Nix store (the original was an 8 MB PNG in
  # ~/.local/share/backgrounds).
  wallpaper = {
    picture-uri = "file://${./wallpaper.jpg}";
    picture-options = "zoom";
    color-shading-type = "solid";
    primary-color = "#000000000000";
    secondary-color = "#000000000000";
  };

  # A GWeather location: (version 2, <(name, station code, is-city,
  # [(latitude, longitude)], [nearby (latitude, longitude)])>)
  victoriaHarbour = mkVariant (mkTuple [
    (mkUint32 2)
    (mkVariant (mkTuple [
      "Victoria Harbour"
      "CYWH"
      false
      [ (mkTuple [ 0.84503025199168524 (-2.1525727383085753) ]) ]
      (mkEmptyArray (type.tupleOf [ type.double type.double ]))
    ]))
  ]);
in
{
  dconf.settings = {
    # Dash/dock pins: Google Chrome only, same as the Mac Dock (persistent-apps).
    # Running apps still show while open; anything pinned by hand is reset
    # on the next switch.
    "org/gnome/shell" = {
      favorite-apps = [ "google-chrome.desktop" ];
    };

    # Screen blank, lock and idle suspend. Values match what was set in
    # GNOME Settings on 2026-10-24, so the first switch changed nothing.
    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 900; # blank after 15 min
    };
    "org/gnome/desktop/screensaver" = wallpaper // {
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

    # Interface: dark style, 12-hour clock, battery percentage in the top bar,
    # middle-click paste kept on (newer GNOME turns it off by default).
    # Accent, fonts, GTK and icon themes are left at GNOME's defaults.
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-format = "12h";
      show-battery-percentage = true;
      gtk-enable-primary-paste = true;
    };
    # Window buttons on the left: close, then minimize (no maximize)
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize:appmenu";
    };
    # Weather (top-bar weather/clock extension and the Weather app): follow the
    # current location, with Victoria Harbour (CYWH) as the saved place.
    # Coordinates are radians; Nix keeps 6 decimals, a few metres off.
    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = [ victoriaHarbour ];
    };
    "org/gnome/Weather" = {
      locations = [ victoriaHarbour ];
    };

    # Keyboard: US layout; Ctrl+Alt+Backspace ends the session
    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };
    # Shortcuts: Super+S Settings, Super+H home folder, Super+F search,
    # Super+T Console. The default minimize shortcut and the overview toggle
    # (Super alone) are switched off.
    "org/gnome/settings-daemon/plugins/media-keys" = {
      control-center = [ "<Super>s" ];
      home = [ "<Super>h" ];
      search = [ "<Super>f" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Console";
      command = "kgx";
      binding = "<Super>t";
    };
    "org/gnome/desktop/wm/keybindings" = {
      minimize = [ ];
    };
    "org/gnome/shell/keybindings" = {
      toggle-overview = [ ];
    };

    # Touchpad: tap to click, two-finger scrolling
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    # Extension settings (enabling the extensions stays manual by design).
    # Shell theme for the User Themes extension (flat-remix-gnome package)
    "org/gnome/shell/extensions/user-theme" = {
      name = "Flat-Remix-Blue-Dark";
    };
    # Dash to Dock: bottom, 32px icons, hides when a window overlaps it,
    # grey background with dynamic transparency, no trash icon, external
    # monitor (DP-1) preferred
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dash-max-icon-size = 32;
      height-fraction = 0.9;
      intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
      disable-overview-on-startup = true;
      show-favorites = true;
      show-running = true;
      show-trash = false;
      show-icons-notifications-counter = false;
      running-indicator-style = "DOTS";
      unity-backlit-items = false;
      preview-size-scale = 0.14;
      apply-custom-theme = false;
      custom-theme-shrink = true;
      custom-background-color = true;
      background-color = "rgb(119,118,123)";
      background-opacity = 0.5;
      transparency-mode = "DYNAMIC";
      multi-monitor = false;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "DP-1";
    };
    # Blur my Shell: blurred dock, unblurred top bar
    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      static-blur = true;
      brightness = 0.6;
      sigma = 50;
      override-background = false;
      style-dash-to-dock = 0;
      pipeline = "pipeline_default_rounded";
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
      brightness = 0.6;
      sigma = 50;
    };
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = 0.6;
      sigma = 50;
    };
    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness = 0.6;
      sigma = 50;
    };
    # Just Perfection: no Activities button, no app menu label, no running-app
    # dots in the dash, start on the desktop instead of the overview
    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = false;
      app-menu-label = false;
      dash-app-running = false;
      notification-banner-position = 2;
      startup-status = 0;
      theme = true;
    };
    # Vitals: memory and CPU in the top bar
    "org/gnome/shell/extensions/vitals" = {
      hot-sensors = [ "_memory_usage_" "_processor_usage_" ];
      position-in-panel = 2;
      fixed-widths = true;
      hide-icons = false;
      hide-zeros = false;
      show-battery = false;
      show-system = true;
      use-higher-precision = true;
    };
    # Freon: average temperature in the top bar
    "org/gnome/shell/extensions/freon" = {
      hot-sensors = [ "__average__" ];
      panel-box-index = 1;
      position-in-panel = 2;
      use-drive-nvmecli = false;
    };
    # Bedtime Mode: automatic schedule (ending at 5 am); button shows while active
    "org/gnome/shell/extensions/bedtime-mode" = {
      automatic-schedule = true;
      schedule-end-hours = 5;
      ondemand-button-visibility = "active-schedule";
    };
    # User avatar in Quick Settings
    "org/gnome/shell/extensions/quick-settings-avatar" = {
      avatar-size = 43;
    };

    # Console: night theme. custom-font only takes effect if "use system
    # font" is turned off in Console's preferences (it isn't today).
    "org/gnome/Console" = {
      theme = "night";
      custom-font = "Anonymous Pro for Powerline 10";
    };
    # Files: list view by default, item counts for every folder
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-directory-item-counts = "always";
    };
    "org/gnome/nautilus/icon-view" = {
      captions = [ "size" "type" "none" ];
    };
    # Open/save dialogs show hidden files (GTK 3 and GTK 4 apps)
    "org/gtk/settings/file-chooser" = {
      show-hidden = true;
      clock-format = "12h";
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
      sort-directories-first = true;
    };
    # Overview search: Calculator and Calendar results off
    "org/gnome/desktop/search-providers" = {
      disabled = [ "org.gnome.Calculator.desktop" "org.gnome.Calendar.desktop" ];
    };

    # Desktop wallpaper, same picture in light and dark style
    "org/gnome/desktop/background" = wallpaper // {
      picture-uri-dark = wallpaper.picture-uri;
    };
  };
}
