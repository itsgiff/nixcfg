# ~/.nixcfg/hosts/x1/gnome.nix
# GNOME settings for the x1, written to dconf by Home Manager on every switch.
# A setting changed by hand in GNOME is put back to these values on the next
# switch; a key removed from here is reset to GNOME's default.
# To find what a toggle writes: run `dconf watch /`, change it, read the key.
# uint32 keys need mkUint32; dconf rejects a plain int for them.
{ lib, ... }:

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
  };
}
