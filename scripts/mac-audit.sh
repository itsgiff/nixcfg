#!/usr/bin/env bash
# ~/.nixcfg/scripts/mac-audit.sh
# Read-only inventory of macOS state that nixcfg doesn't declare yet:
#   apps (cask / App Store / Nix / pkg / unmanaged), third-party and Apple
#   preference domains, Dock items, dotfiles, launchd jobs, fonts, login items.
#
# Usage: scripts/mac-audit.sh [--login-items] [--containers] [outdir]
#   --login-items  also list login items (asks for Automation access to System Events)
#   --containers   also list sandboxed apps' prefs (may trigger a privacy prompt)
#   outdir         default: ~/nixcfg-audit-YYYYmmdd-HHMM
# Needs: jq (Homebrew). Works with macOS's bash 3.2.
set -u

LOGIN=0; CONTAINERS=0; OUT=""
for a in "$@"; do
  case "$a" in
    --login-items) LOGIN=1 ;;
    --containers)  CONTAINERS=1 ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    *) OUT="$a" ;;
  esac
done
REPO="${NIXCFG:-$HOME/.nixcfg}"
OUT="${OUT:-$HOME/nixcfg-audit-$(date +%Y%m%d-%H%M)}"
mkdir -p "$OUT"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

have() { command -v "$1" >/dev/null 2>&1; }
have jq || { echo "jq is required (brew install jq)"; exit 1; }
# Does the repo mention this string anywhere in its .nix files?
in_repo() { grep -rqF --include='*.nix' -e "$1" "$REPO" 2>/dev/null; }
bundle_id() { /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$1/Contents/Info.plist" 2>/dev/null; }

echo "Writing report to $OUT"

# ---------------------------------------------------------------- 1. apps
# app name -> cask token, for installed casks and (offline) for every cask
brew info --json=v2 --installed 2>/dev/null | jq -r '
  .casks[] | .token as $t | .artifacts[]? | objects | .app? // empty
  | ((map(objects | .target) | first) // (map(strings) | first)) // empty
  | "\(split("/") | last)\t\($t)"' > "$TMP/cask-installed" 2>/dev/null
# Cask suggestions for apps not installed by Homebrew: match app names and
# bundle-id parts against Homebrew's cask name list, then keep only casks
# whose app artifact really has that name.
list_apps() {
  for dir in /Applications "$HOME/Applications"; do
    [ -d "$dir" ] && find "$dir" -maxdepth 3 -name '*.app' -prune -print 2>/dev/null
  done | sort -u
}
: > "$TMP/cask-all"
CASK_NAMES="$(brew --cache 2>/dev/null)/api/cask_names.txt"
if [ -f "$CASK_NAMES" ]; then
  list_apps | while IFS= read -r app; do
    n=$(basename "$app" .app)
    printf '%s\n%s\n' "$n" "$(printf '%s' "$n" | sed -E 's/ [0-9.]+$//; s/\.(us|app)$//')"
    bundle_id "$app" | tr '.' '\n'
  done | tr 'A-Z' 'a-z' | sed -E 's/[^a-z0-9+]+/-/g; s/^-+//; s/-+$//' | grep -v '^$' | sort -u > "$TMP/guesses"
  grep -Fx -f "$TMP/guesses" "$CASK_NAMES" > "$TMP/cands" 2>/dev/null
  if [ -s "$TMP/cands" ]; then
    # shellcheck disable=SC2046
    brew info --json=v2 --cask $(cat "$TMP/cands") 2>/dev/null | jq -r '
      .casks[] | .token as $t | .artifacts[]? | objects | .app? // empty
      | ((map(objects | .target) | first) // (map(strings) | first)) // empty
      | "\(split("/") | last)\t\($t)"' > "$TMP/cask-all" 2>/dev/null
  fi
fi
lookup() { awk -F'\t' -v n="$1" '$1==n {print $2; exit}' "$2"; }

have mas && mas list 2>/dev/null > "$TMP/mas" || : > "$TMP/mas"

printf 'status\tsource\tapp\tbundle_id\tsuggestion\n' > "$OUT/apps.tsv"
: > "$TMP/bundles"
list_apps | while IFS= read -r app; do
  name=$(basename "$app"); short=${name%.app}
  bid=$(bundle_id "$app")
  printf '%s\t%s\n' "$bid" "$short" >> "$TMP/bundles"
  src=""; status=""; sugg=""
  case "$app" in
    */Nix\ Apps/*|*/Home\ Manager\ Apps/*|*/Nix\ Trampolines/*) src=nix; status=ok ;;
  esac
  if [ -z "$src" ] && [ -L "$app" ] && readlink "$app" | grep -q '^/nix/store'; then src=nix; status=ok; fi
  if [ -z "$src" ] && [ -d "$app/Contents/_MASReceipt" ]; then
    src=mas
    if in_repo "\"$short\""; then status=ok; else
      status=UNDECLARED
      id=$(awk -v n="$short" '{ $1=$1 } index($0, n) {print $1; exit}' "$TMP/mas")
      sugg="masApps.\"$short\" = ${id:-<id from: mas list>};"
    fi
  fi
  if [ -z "$src" ]; then
    tok=$(lookup "$name" "$TMP/cask-installed")
    if [ -n "$tok" ]; then
      src=cask
      if in_repo "\"$tok\""; then status=ok; else status=UNDECLARED; sugg="casks: \"$tok\""; fi
    fi
  fi
  if [ -z "$src" ]; then
    case "$bid" in com.apple.*) src=apple; status=ok ;; esac
  fi
  if [ -z "$src" ]; then
    pkg=$(pkgutil --file-info "$app" 2>/dev/null | awk '/^pkgid:/ {print $2; exit}')
    tok=$(lookup "$name" "$TMP/cask-all")
    if [ -n "$pkg" ]; then
      src="pkg"; status=CHECK; sugg="installer pkg $pkg (part of a declared cask?)"
    else
      src=manual; status=UNMANAGED
    fi
    [ -n "$tok" ] && sugg="cask available: \"$tok\"${sugg:+; $sugg}"
  fi
  printf '%s\t%s\t%s\t%s\t%s\n' "$status" "$src" "$short" "$bid" "$sugg" >> "$OUT/apps.tsv"
done
# put the actionable rows first
{ head -1 "$OUT/apps.tsv"; tail -n +2 "$OUT/apps.tsv" | sort -t$'\t' -k1,1r -k3,3; } > "$TMP/a" && mv "$TMP/a" "$OUT/apps.tsv"

# ------------------------------------------- 2. third-party preference domains
printf 'keys\tdomain\tapp\tin_repo\n' > "$OUT/prefs-thirdparty.tsv"
defaults domains 2>/dev/null | tr ',' '\n' | sed 's/^ *//' | grep -v '^com\.apple\.' | grep -v '^$' | sort -u |
while IFS= read -r d; do
  n=$(defaults read "$d" 2>/dev/null | grep -cE '^    [^ )}]')
  app=$(awk -F'\t' -v b="$d" '$1==b {print $2; exit}' "$TMP/bundles")
  r=no; in_repo "$d" && r=yes
  printf '%s\t%s\t%s\t%s\n' "$n" "$d" "${app:--}" "$r" >> "$OUT/prefs-thirdparty.tsv"
done
if [ "$CONTAINERS" = 1 ]; then
  for p in "$HOME"/Library/Containers/*/Data/Library/Preferences/*.plist; do
    [ -f "$p" ] || continue
    d=$(basename "$p" .plist)
    case "$d" in com.apple.*) continue ;; esac
    n=$(defaults read "$p" 2>/dev/null | grep -cE '^    [^ )}]')
    printf '%s\t%s\t%s\t%s\n' "$n" "$d" "(sandboxed)" "no" >> "$OUT/prefs-thirdparty.tsv"
  done
fi

# ---------------------------------------- 3. Apple settings commonly tweaked
# A key that exists in your user domain was written by you (or by macOS when
# you touched the setting). Keys the repo already names are skipped.
printf 'domain\tkey\tvalue\n' > "$OUT/prefs-apple.tsv"
while IFS='|' read -r dom key; do
  [ -z "$dom" ] && continue
  case "$dom" in
    @host:*) dom=${dom#@host:}; v=$(defaults -currentHost read "$dom" "$key" 2>/dev/null) || continue; dom="$dom (currentHost)" ;;
    *) v=$(defaults read "$dom" "$key" 2>/dev/null) || continue ;;
  esac
  in_repo "$key" && continue
  v=$(printf '%s' "$v" | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-120)
  printf '%s\t%s\t%s\n' "$dom" "$key" "$v" >> "$OUT/prefs-apple.tsv"
done <<'EOF'
com.apple.dock|wvous-tl-corner
com.apple.dock|wvous-tr-corner
com.apple.dock|wvous-bl-corner
com.apple.dock|wvous-br-corner
com.apple.dock|magnification
com.apple.dock|largesize
com.apple.dock|autohide-delay
com.apple.dock|autohide-time-modifier
com.apple.dock|expose-group-apps
com.apple.dock|show-process-indicators
com.apple.dock|minimize-to-application
com.apple.dock|launchanim
com.apple.dock|static-only
com.apple.finder|FXDefaultSearchScope
com.apple.finder|_FXSortFoldersFirst
com.apple.finder|_FXShowPosixPathInTitle
com.apple.finder|NewWindowTarget
com.apple.finder|NewWindowTargetPath
com.apple.finder|ShowExternalHardDrivesOnDesktop
com.apple.finder|ShowHardDrivesOnDesktop
com.apple.finder|ShowRemovableMediaOnDesktop
com.apple.finder|ShowMountedServersOnDesktop
com.apple.finder|FXRemoveOldTrashItems
com.apple.finder|AppleShowAllFiles
NSGlobalDomain|AppleInterfaceStyle
NSGlobalDomain|AppleInterfaceStyleSwitchesAutomatically
NSGlobalDomain|AppleAccentColor
NSGlobalDomain|AppleHighlightColor
NSGlobalDomain|AppleShowScrollBars
NSGlobalDomain|AppleTemperatureUnit
NSGlobalDomain|AppleMeasurementUnits
NSGlobalDomain|AppleMetricUnits
NSGlobalDomain|AppleICUForce24HourTime
NSGlobalDomain|ApplePressAndHoldEnabled
NSGlobalDomain|AppleWindowTabbingMode
NSGlobalDomain|AppleSpacesSwitchOnActivate
NSGlobalDomain|AppleEnableSwipeNavigateWithScrolls
NSGlobalDomain|NSTableViewDefaultSizeMode
NSGlobalDomain|NSDocumentSaveNewDocumentsToCloud
NSGlobalDomain|NSWindowShouldDragOnGesture
NSGlobalDomain|_HIHideMenuBar
NSGlobalDomain|com.apple.mouse.tapBehavior
NSGlobalDomain|com.apple.trackpad.scaling
NSGlobalDomain|com.apple.mouse.scaling
NSGlobalDomain|com.apple.sound.beep.feedback
NSGlobalDomain|com.apple.sound.beep.volume
NSGlobalDomain|com.apple.keyboard.fnState
com.apple.menuextra.clock|ShowSeconds
com.apple.menuextra.clock|ShowDate
com.apple.menuextra.clock|ShowDayOfWeek
com.apple.menuextra.clock|ShowAMPM
com.apple.menuextra.clock|IsAnalog
com.apple.controlcenter|NSStatusItem Visible Battery
com.apple.controlcenter|NSStatusItem Visible BentoBox
com.apple.controlcenter|NSStatusItem Visible Bluetooth
com.apple.controlcenter|NSStatusItem Visible WiFi
com.apple.controlcenter|NSStatusItem Visible Sound
com.apple.controlcenter|NSStatusItem Visible NowPlaying
com.apple.controlcenter|NSStatusItem Visible FocusModes
com.apple.controlcenter|NSStatusItem Visible Display
@host:com.apple.controlcenter|BatteryShowPercentage
com.apple.WindowManager|GloballyEnabled
com.apple.WindowManager|EnableStandardClickToShowDesktop
com.apple.WindowManager|EnableTilingByEdgeDrag
com.apple.WindowManager|EnableTopTilingByEdgeDrag
com.apple.WindowManager|EnableTiledWindowMargins
com.apple.WindowManager|HideDesktop
com.apple.WindowManager|StandardHideWidgets
com.apple.spaces|spans-displays
com.apple.screencapture|disable-shadow
com.apple.screencapture|show-thumbnail
com.apple.screencapture|target
com.apple.screensaver|askForPassword
com.apple.screensaver|askForPasswordDelay
@host:com.apple.screensaver|idleTime
com.apple.desktopservices|DSDontWriteNetworkStores
com.apple.desktopservices|DSDontWriteUSBStores
com.apple.LaunchServices|LSQuarantine
com.apple.HIToolbox|AppleFnUsageType
com.apple.AppleMultitouchTrackpad|TrackpadThreeFingerHorizSwipeGesture
com.apple.AppleMultitouchTrackpad|TrackpadThreeFingerVertSwipeGesture
com.apple.AppleMultitouchTrackpad|TrackpadFourFingerHorizSwipeGesture
com.apple.AppleMultitouchTrackpad|TrackpadTwoFingerFromRightEdgeSwipeGesture
com.apple.AppleMultitouchTrackpad|TrackpadPinch
com.apple.AppleMultitouchTrackpad|TrackpadRotate
com.apple.AppleMultitouchTrackpad|FirstClickThreshold
com.apple.TimeMachine|DoNotOfferNewDisksForBackup
com.apple.ActivityMonitor|ShowCategory
com.apple.TextEdit|RichText
com.apple.Terminal|Default Window Settings
com.apple.universalaccess|reduceMotion
com.apple.universalaccess|reduceTransparency
EOF

# Dock items (system.defaults.dock.persistent-apps / persistent-others)
{
  echo "# Dock items, in order. Candidate for system.defaults.dock.persistent-apps"
  if have dockutil; then dockutil --list 2>/dev/null | awk -F'\t' '{print $2 "\t" $1}' | sed 's#^file://##; s#%20# #g'
  else defaults read com.apple.dock persistent-apps 2>/dev/null | grep '_CFURLString"' | sed 's/.*= "//; s/";//; s#file://##; s#%20# #g'
  fi
} > "$OUT/dock.txt"

# ---------------------------------------------------------------- 4. dotfiles
# Unmanaged = not a symlink into /nix/store; "partial" = a directory with some HM links.
NOISE='^\.(Trash|DS_Store|CFUserTextEncoding|cache|local|zsh_history|zsh_sessions|bash_history|bash_sessions|lesshst|viminfo|python_history|node_repl_history|psql_history|sqlite_history|wget-hsts|nix-profile|nix-defexpr|cups|ssh|gnupg|npm|cargo|rustup|pnpm-state|hm-bak|swiftpm|vscode|cups|Xauthority|z)$'
{
  echo "# status  path   (secrets/state such as ~/.ssh, ~/.gnupg, ~/.aws are deliberately left out of nixcfg)"
  for f in "$HOME"/.[!.]* "$HOME"/.config/*; do
    [ -e "$f" ] || [ -L "$f" ] || continue
    b=$(basename "$f")
    printf '%s' "$b" | grep -Eq "$NOISE" && continue
    case "$f" in "$HOME/.config") continue ;; esac
    case "$b" in *.hm-bak) echo "HM-BAK     ${f#"$HOME"/}"; continue ;; esac
    if [ -L "$f" ] && readlink "$f" | grep -q '^/nix/store'; then continue; fi
    if [ -d "$f" ] && [ -n "$(find "$f" -maxdepth 3 -type l -lname '/nix/store/*' -print -quit 2>/dev/null)" ]; then
      extra=$(find "$f" -maxdepth 3 -type f ! -name '*.hm-bak' ! -path '*/cache*' ! -path '*/fish_variables' 2>/dev/null | head -5 | sed "s#$HOME/##" | tr '\n' ' ')
      echo "partial    ${f#"$HOME"/}   unmanaged files: ${extra:-none}"
    else
      echo "UNMANAGED  ${f#"$HOME"/}"
    fi
  done
  find "$HOME" "$HOME/.config" -maxdepth 4 -name '*.hm-bak' 2>/dev/null | sed "s#$HOME/#HM-BAK     #"
} | sort -u > "$OUT/dotfiles.txt"

# ---------------------------------------------------------------- 5. launchd
{
  echo "# user agents (~/Library/LaunchAgents)"
  for p in "$HOME"/Library/LaunchAgents/*.plist; do
    [ -e "$p" ] || continue
    if [ -L "$p" ] && readlink "$p" | grep -q '^/nix/store'; then s=nix; else s=UNMANAGED; fi
    case "$(basename "$p")" in homebrew.mxcl.*) s="brew services" ;; esac
    echo "$s  $(basename "$p" .plist)  $(/usr/libexec/PlistBuddy -c 'Print :Program' "$p" 2>/dev/null || /usr/libexec/PlistBuddy -c 'Print :ProgramArguments:0' "$p" 2>/dev/null)"
  done
  echo; echo "# system agents and daemons (/Library), non-Apple"
  for p in /Library/LaunchAgents/*.plist /Library/LaunchDaemons/*.plist; do
    [ -e "$p" ] || continue
    b=$(basename "$p" .plist)
    case "$b" in org.nixos.*|systems.determinate.*) s=nix ;; *) s="app-installed" ;; esac
    echo "$s  $b"
  done
} > "$OUT/launchd.txt"

# ------------------------------------------------------------ 6. fonts, login
{ echo "# user fonts (candidates for fonts.packages)"; ls "$HOME/Library/Fonts" 2>/dev/null; } > "$OUT/fonts.txt"
if [ "$LOGIN" = 1 ]; then
  osascript -e 'tell application "System Events" to get the name of every login item' 2>&1 | tr ',' '\n' | sed 's/^ *//' > "$OUT/login-items.txt"
fi

# ---------------------------------------------------------------- summary
c() { grep -c "$1" "$2" 2>/dev/null || true; }
{
  echo "# nixcfg audit — $(scutil --get LocalHostName 2>/dev/null) — $(date '+%Y-%m-%d %H:%M')"
  echo
  echo "| area | count | file |"
  echo "|---|---|---|"
  echo "| apps not from Homebrew/App Store/Nix | $(c '^UNMANAGED' "$OUT/apps.tsv") | apps.tsv |"
  echo "| apps installed but not declared | $(c '^UNDECLARED' "$OUT/apps.tsv") | apps.tsv |"
  echo "| pkg-installed apps to check | $(c '^CHECK' "$OUT/apps.tsv") | apps.tsv |"
  echo "| third-party pref domains (not in repo) | $(awk -F'\t' 'NR>1 && $4=="no" && $1>0' "$OUT/prefs-thirdparty.tsv" | wc -l | tr -d ' ') | prefs-thirdparty.tsv |"
  echo "| Apple settings set but not in repo | $(($(wc -l < "$OUT/prefs-apple.tsv") - 1)) | prefs-apple.tsv |"
  echo "| unmanaged dotfiles | $(c '^UNMANAGED' "$OUT/dotfiles.txt") | dotfiles.txt |"
  echo "| leftover *.hm-bak files | $(c '^HM-BAK' "$OUT/dotfiles.txt") | dotfiles.txt |"
  echo "| unmanaged user LaunchAgents | $(c '^UNMANAGED' "$OUT/launchd.txt") | launchd.txt |"
  echo "| user fonts | $(($(wc -l < "$OUT/fonts.txt") - 1)) | fonts.txt |"
  if [ ! -s "$TMP/cask-all" ]; then
    echo; echo "Note: no cask suggestions found for manual apps (Homebrew's cask name list missing, or no matches)."
  fi
} > "$OUT/SUMMARY.md"
cat "$OUT/SUMMARY.md"
echo
echo "Next: column -t -s \$'\\t' $OUT/apps.tsv | less -S"
