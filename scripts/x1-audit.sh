#!/usr/bin/env bash
# ~/.nixcfg/scripts/x1-audit.sh
# Read-only inventory of NixOS/GNOME state on the x1 that nixcfg doesn't declare:
#   dconf settings (grouped, with what Home Manager already declares marked),
#   apps installed outside the system config, autostart entries, user systemd
#   units, GNOME extensions, user fonts, unmanaged dotfiles, *.hm-bak leftovers.
#
# Usage: scripts/x1-audit.sh [outdir]      (default: ~/nixcfg-audit-YYYYmmdd-HHMM)
# Needs: dconf, dconf2nix, jq, nix (all in the x1 system packages). Changes nothing.
set -u

OUT="${1:-$HOME/nixcfg-audit-$(date +%Y%m%d-%H%M)}"
REPO="${NIXCFG:-$HOME/.nixcfg}"
HOST="${HOSTNAME_OVERRIDE:-$(hostname)}"
mkdir -p "$OUT"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
have() { command -v "$1" >/dev/null 2>&1; }
is_nix_link() { [ -L "$1" ] && readlink -f "$1" | grep -q '^/nix/store/'; }
echo "Writing report to $OUT"

# ------------------------------------------------------------------ 1. dconf
# Everything in the user dconf database was written by hand (GNOME Settings,
# Tweaks, an extension's prefs) or by Home Manager. State that changes on its
# own (window sizes, recent/last-used, timestamps, history) is dropped.
# Skipped sections: app state, per-connection network flags, shortcuts apps
# register themselves (global-shortcuts).
SKIP_SEC='^(org/gnome/control-center|org/gnome/evolution-data-server|org/gnome/portal|org/gnome/software|org/gnome/desktop/notifications/application|org/gnome/desktop/app-folders|org/gnome/nautilus/window-state|ca/desrt/dconf-editor|org/gnome/epiphany/state|org/gnome/nm-applet/eap|org/gnome/settings-daemon/global-shortcuts|apps/seahorse)|/state(/|$)|/windows?(/|$)|window-state'
SKIP_KEY='^(window-.*|last-.*|recent.*|.*-history|.*timestamp.*|.*maximized|.*geometry|width|height|sidebar-width|sidebar-size|name-column-width|col-[0-9]+-(width|visible)|current-tab|selected-color|custom-colors|donation-reminder-last-shown|support-notifier-.*|settings-version|rounded-blur-found|app-picker-layout|welcome-dialog-last-shown-version|application-children|night-light-last-coordinates|migrated.*|first-run|enabled-extensions|disabled-extensions)$'

dconf dump / | awk -v ss="$SKIP_SEC" -v sk="$SKIP_KEY" '
  /^\[.*\]$/ { sec = substr($0, 2, length($0) - 2); skip = (sec ~ ss); next }
  skip || /^[[:space:]]*$/ { next }
  { k = $0; sub(/=.*/, "", k); if (k ~ sk) next
    v = substr($0, length(k) + 2); print sec "\t" k "\t" v }' > "$TMP/dconf.tsv"

# Keys Home Manager declares (exact, from the evaluated config)
DECLARED_OK=1
nix eval --json "$REPO#nixosConfigurations.$HOST.config.home-manager.users.$USER.dconf.settings" \
  --apply 'builtins.mapAttrs (p: v: builtins.attrNames v)' 2>"$TMP/eval.err" \
  | jq -r 'to_entries[] | .key as $p | .value[] | "\($p)\t\(.)"' > "$TMP/declared.tsv" \
  || DECLARED_OK=0
[ -s "$TMP/declared.tsv" ] || DECLARED_OK=0

group() {  # path -> report group
  case "$1" in
    org/gnome/shell/extensions/*)                           echo "5 extensions and their settings" ;;
    org/gnome/desktop/input-sources|org/gnome/desktop/wm/keybindings|org/gnome/shell/keybindings|org/gnome/mutter/keybindings|org/gnome/mutter/wayland/keybindings|org/gnome/settings-daemon/plugins/media-keys*|org/gnome/desktop/peripherals/keyboard)
                                                            echo "2 keyboard and shortcuts" ;;
    org/gnome/desktop/peripherals/*)                        echo "3 touchpad and mouse" ;;
    org/gnome/settings-daemon/plugins/power|org/gnome/desktop/session|org/gnome/desktop/screensaver|org/gnome/desktop/lockdown|org/gnome/desktop/privacy|org/gnome/settings-daemon/plugins/color)
                                                            echo "4 power, lock, privacy, night light" ;;
    org/gnome/desktop/interface|org/gnome/desktop/background|org/gnome/desktop/wm/preferences|org/gnome/mutter|org/gnome/shell|org/gnome/desktop/sound|org/gnome/desktop/a11y*|org/gnome/desktop/calendar|org/gnome/desktop/datetime|system/locale|org/gnome/system/location|org/gnome/shell/weather|org/gnome/shell/world-clocks|org/gnome/GWeather4)
                                                            echo "1 interface, appearance, windows, clock" ;;
    *)                                                      echo "6 app settings" ;;
  esac
}
: > "$TMP/marked.tsv"
while IFS=$'\t' read -r p k v; do
  if [ "$DECLARED_OK" = 1 ] && grep -qxF "$p"$'\t'"$k" "$TMP/declared.tsv"; then st=declared; else st=NEW; fi
  printf '%s\t%s\t%s\t%s\t%s\n' "$(group "$p")" "$st" "$p" "$k" "$v" >> "$TMP/marked.tsv"
done < "$TMP/dconf.tsv"
sort -t$'\t' -k1,1 -k3,3 -k4,4 "$TMP/marked.tsv" > "$TMP/sorted.tsv"

{
  echo "# dconf: settings stored for $USER, not yet declared in nixcfg"
  [ "$DECLARED_OK" = 1 ] || echo "WARNING: couldn't evaluate the flake ($(head -1 "$TMP/eval.err")); nothing is marked declared."
  echo "# state keys (window sizes, last-used, history, timestamps) and enabled-extensions are left out"
  awk -F'\t' '
    $1 != g { g = $1; print ""; print "## " substr(g, 3) }
    $2 == "NEW" { if ($3 != p) { print "[" $3 "]"; p = $3 } v = $5; for (i = 6; i <= NF; i++) v = v "\t" $i; print $4 "=" v; next }
    { d[g]++ }
    END { for (x in d) printf "\n(%d already-declared keys in \"%s\" not shown)\n", d[x], substr(x, 3) }' "$TMP/sorted.tsv"
} > "$OUT/dconf.md"

# Same NEW keys as a Home Manager snippet, ready to copy from
awk -F'\t' '$2 == "NEW" { if ($3 != p) { if (p != "") print ""; print "[" $3 "]"; p = $3 }
  v = $5; for (i = 6; i <= NF; i++) v = v "\t" $i; print $4 "=" v }' "$TMP/sorted.tsv" > "$TMP/new.ini"
# dconf2nix rejects some values (e.g. typed empty arrays like @a(dd) []).
# Drop the line it names and retry, so one odd key doesn't lose the rest.
if have dconf2nix && [ -s "$TMP/new.ini" ]; then
  : > "$TMP/d2n.dropped"
  for _ in $(seq 1 25); do
    dconf2nix -i "$TMP/new.ini" -o "$OUT/dconf-new.nix" 2>"$TMP/d2n.err" && break
    ln=$(grep -oE 'line [0-9]+' "$TMP/d2n.err" | head -1 | cut -d' ' -f2)
    [ -n "$ln" ] || { echo "# dconf2nix failed: $(head -1 "$TMP/d2n.err")" > "$OUT/dconf-new.nix"; break; }
    sec=$(head -n "$ln" "$TMP/new.ini" | grep '^\[' | tail -1)
    echo "$sec $(sed -n "${ln}p" "$TMP/new.ini" | cut -d= -f1)" >> "$TMP/d2n.dropped"
    sed -i "${ln}d" "$TMP/new.ini"
  done
  if [ -s "$TMP/d2n.dropped" ] && [ -f "$OUT/dconf-new.nix" ]; then
    { echo "# Left out (dconf2nix can't parse the value; see dconf.md):"
      sed 's/^/#   /' "$TMP/d2n.dropped"; cat "$OUT/dconf-new.nix"; } > "$TMP/d2n.nix" && mv "$TMP/d2n.nix" "$OUT/dconf-new.nix"
  fi
fi

# ------------------------------------------------- 2. apps outside the config
{
  echo "# Apps and binaries installed outside nixcfg"
  echo; echo "## Flatpak"
  if have flatpak; then flatpak list --app --columns=application,name,origin 2>/dev/null; else echo "(flatpak not installed)"; fi
  echo; echo "## Imperative Nix installs (nix profile / nix-env into ~/.nix-profile)"
  nix profile list 2>/dev/null | grep -E '^(Name|Flake attribute|Original flake URL|Store paths):' || true
  nix-env -q 2>/dev/null | sed 's/^/nix-env: /' || true
  [ -d "$HOME/.nix-profile/bin" ] && ls "$HOME/.nix-profile/bin" | sed 's/^/~\/.nix-profile\/bin: /'
  echo; echo "## AppImages"
  find "$HOME" -xdev -maxdepth 4 \( -path "$HOME/.cache" -o -path "$HOME/.local/share/Trash" \) -prune -o -iname '*.appimage' -print 2>/dev/null | sed "s#$HOME#~#"
  echo; echo "## Loose binaries"
  for d in "$HOME/.local/bin" "$HOME/bin" "$HOME/Applications" "$HOME/.cargo/bin" "$HOME/go/bin" "$HOME/.npm-global/bin" /opt /usr/local/bin; do
    [ -d "$d" ] && [ -n "$(ls -A "$d" 2>/dev/null)" ] && { echo "${d/#$HOME/~}:"; ls -A "$d" | sed 's/^/  /'; }
  done
  have pipx && { echo "pipx:"; pipx list --short 2>/dev/null | sed 's/^/  /'; }
  have npm && { echo "npm -g:"; npm ls -g --depth=0 2>/dev/null | tail -n +2 | sed 's/^/  /'; }
  echo; echo "## Hand-made launchers in ~/.local/share/applications (e.g. Chrome 'Install as app')"
  for f in "$HOME"/.local/share/applications/*.desktop; do
    [ -e "$f" ] || continue
    is_nix_link "$f" && continue
    printf '%s\t%s\n' "$(basename "$f")" "$(grep -m1 '^Exec=' "$f" | cut -c6-120)"
  done
  echo; echo "## Printers added by hand (CUPS queues; nixcfg relies on driverless discovery)"
  have lpstat && lpstat -v 2>/dev/null || echo "(none or lpstat missing)"
} > "$OUT/apps.txt"

# ---------------------------------------------- 3. autostart, systemd, cron
{
  echo "# ~/.config/autostart (status  file  Exec  [binary found?])"
  for f in "$HOME"/.config/autostart/*.desktop; do
    [ -e "$f" ] || continue
    if is_nix_link "$f"; then s=nix; else s=UNMANAGED; fi
    ex=$(grep -m1 '^Exec=' "$f" | cut -c6-); bin=${ex%% *}
    if have "$bin" || [ -x "$bin" ]; then found="binary found"; else found="BINARY MISSING (stale entry?)"; fi
    off=$(grep -Eqi '^(Hidden=true|X-GNOME-Autostart-enabled=false)' "$f" && echo " (disabled)")
    echo "$s  $(basename "$f")  $ex  [$found]$off"
  done
  echo; echo "# ~/.config/systemd/user (hand-written units and hand-made enable links)"
  if [ -d "$HOME/.config/systemd/user" ]; then
    find "$HOME/.config/systemd/user" -mindepth 1 \( -type f -o -type l \) | sort | while read -r f; do
      if is_nix_link "$f"; then s=nix
      elif [ -L "$f" ]; then s="ENABLE-LINK -> $(readlink "$f")"
      else s=UNIT-FILE; fi
      echo "${f#"$HOME"/.config/systemd/user/}  $s"
    done
  else echo "(none)"; fi
  echo; echo "# crontab"
  crontab -l 2>/dev/null || echo "(none)"
} > "$OUT/autostart-systemd.txt"

# ---------------------------------------------------------- 4. extensions
{
  echo "# GNOME extensions (enabling stays manual by design)"
  printf '%-48s %-6s %s\n' UUID SOURCE STATE
  if have gnome-extensions; then
    gnome-extensions list | sort | while read -r u; do
      info=$(gnome-extensions info "$u" 2>/dev/null)
      path=$(printf '%s\n' "$info" | awk -F': ' 'tolower($1) ~ /path/ {print $2; exit}')
      state=$(printf '%s\n' "$info" | awk -F': ' 'tolower($1) ~ /state|enabled/ {printf "%s=%s ", $1, $2}' | tr -s ' ')
      case "$path" in "$HOME"/*) src=USER ;; *) src=nix ;; esac
      printf '%-48s %-6s %s\n' "$u" "$src" "$state"
    done
  fi
  echo; echo "# Installed by hand (~/.local/share/gnome-shell/extensions)"
  ls -1 "$HOME/.local/share/gnome-shell/extensions" 2>/dev/null || echo "(none)"
} > "$OUT/extensions.txt"

# ---------------------------------------------------------------- 5. fonts
{
  echo "# user fonts (candidates for fonts.packages)"
  for d in "$HOME/.local/share/fonts" "$HOME/.fonts"; do [ -d "$d" ] && find "$d" -type f | sed "s#$HOME#~#"; done
} > "$OUT/fonts.txt"

# -------------------------------------------------------------- 6. dotfiles
# State, caches, secrets and app data dirs are skipped; decided-unmanaged too (gh, omf).
NOISE='^\.(cache|local|ssh|gnupg|pki|mozilla|thunderbird|nix-profile|nix-defexpr|nix-channels|Xauthority|ICEauthority|xsession-errors.*|lesshst|viminfo|python_history|node_repl_history|wget-hsts|bash_history|dbus|var|vscode|npm|cargo|rustup|java|zoom|steam|docker|kube|aws|azure|terraform\.d|config|nixcfg)$'
CFG_NOISE='^(dconf|pulse|google-chrome|chromium|BraveSoftware|discord|Signal|Bitwarden|obsidian|evolution|goa-1\.0|gnome-session|ibus|enchant|libreoffice|Claude|Electron|gh|omf|autostart|systemd|user-dirs\.dirs|user-dirs\.locale|.*\.hm-bak|.*~)$'
{
  echo "# status  path"
  for f in "$HOME"/.[!.]* "$HOME"/.config/*; do
    [ -e "$f" ] || [ -L "$f" ] || continue
    b=$(basename "$f")
    case "$f" in
      "$HOME"/.config/*) printf '%s' "$b" | grep -Eq "$CFG_NOISE" && continue ;;
      *) printf '%s' "$b" | grep -Eq "$NOISE" && continue
         case "$b" in *.hm-bak) continue ;; esac ;;
    esac
    is_nix_link "$f" && continue
    if [ -d "$f" ] && [ -n "$(find "$f" -maxdepth 3 -type l -lname '/nix/store/*' -print -quit 2>/dev/null)" ]; then
      extra=$(find "$f" -maxdepth 3 -type f ! -name '*.hm-bak' ! -ipath '*cache*' ! -name fish_variables 2>/dev/null | head -5 | sed "s#$HOME/##" | tr '\n' ' ')
      echo "partial    ${f#"$HOME"/}   unmanaged files: ${extra:-none}"
    else
      echo "UNMANAGED  ${f#"$HOME"/}"
    fi
  done
  echo; echo "# leftover *.hm-bak (an existing one blocks the next takeover of that file)"
  find "$HOME" -xdev -maxdepth 6 \( -path "$HOME/.cache" -o -path "$HOME/.local/share/Trash" -o -name node_modules \) -prune \
    -o -name '*.hm-bak' -print 2>/dev/null | sed "s#$HOME/#HM-BAK     #"
} > "$OUT/dotfiles.txt"

# ---------------------------------------------------------------- summary
cnt() { grep -c "$1" "$2" 2>/dev/null || true; }
{
  echo "# nixcfg audit — $HOST — $(date '+%Y-%m-%d %H:%M')"
  echo
  echo "| area | count | file |"
  echo "|---|---|---|"
  for g in "1 interface, appearance, windows, clock" "2 keyboard and shortcuts" "3 touchpad and mouse" "4 power, lock, privacy, night light" "5 extensions and their settings" "6 app settings"; do
    n=$(awk -F'\t' -v g="$g" '$1 == g && $2 == "NEW"' "$TMP/sorted.tsv" | wc -l)
    echo "| dconf: ${g#? } (undeclared keys) | $n | dconf.md, dconf-new.nix |"
  done
  echo "| hand-made launchers (.local/share/applications) | $(sed -n '/^## Hand-made/,/^## Printers/p' "$OUT/apps.txt" | grep -c $'\t') | apps.txt |"
  echo "| unmanaged autostart entries | $(cnt '^UNMANAGED' "$OUT/autostart-systemd.txt") | autostart-systemd.txt |"
  echo "| user systemd units / enable links | $(grep -cE '(UNIT-FILE|ENABLE-LINK)' "$OUT/autostart-systemd.txt") | autostart-systemd.txt |"
  echo "| extensions installed by hand | $(grep -c ' USER ' "$OUT/extensions.txt") | extensions.txt |"
  echo "| user fonts | $(($(wc -l < "$OUT/fonts.txt") - 1)) | fonts.txt |"
  echo "| unmanaged dotfiles | $(cnt '^UNMANAGED' "$OUT/dotfiles.txt") | dotfiles.txt |"
  echo "| leftover *.hm-bak | $(cnt '^HM-BAK' "$OUT/dotfiles.txt") | dotfiles.txt |"
  echo
  echo "Apps outside Nix (Flatpak, nix profile, AppImages, loose binaries): see apps.txt"
} > "$OUT/SUMMARY.md"
cat "$OUT/SUMMARY.md"
echo
echo "Bundle for Claude: tar czf ~/nixcfg-audit.tgz -C \"$(dirname "$OUT")\" \"$(basename "$OUT")\""
