# ~/.nixcfg/hosts/x1/gnome.nix
# GNOME settings for the x1, written to dconf by Home Manager on every switch.
# A setting changed by hand in GNOME is put back to these values on the next
# switch; a key removed from here is reset to GNOME's default.
# To find what a toggle writes: run `dconf watch /`, change it, read the key.
# uint32 keys need mkUint32; dconf rejects a plain int for them.
{ lib, ... }:

let
  inherit (lib.hm.gvariant) mkUint32 mkVariant mkTuple mkEmptyArray type;

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

    # Interface: dark style, 12-hour clock, battery percentage in the top bar.
    # Accent, fonts, GTK and icon themes are left at GNOME's defaults.
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-format = "12h";
      show-battery-percentage = true;
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
  };
}
