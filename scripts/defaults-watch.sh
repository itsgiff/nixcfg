#!/usr/bin/env bash
# ~/.nixcfg/scripts/defaults-watch.sh
# Find out which preference a GUI toggle writes, and get a Nix snippet for it.
#
#   scripts/defaults-watch.sh snap   # 1. snapshot every preference domain
#   (change ONE setting in System Settings or the app; close the pane/app)
#   scripts/defaults-watch.sh diff   # 2. changed keys + suggested Nix + other files touched
#
# Covers user domains, -currentHost domains and /Library/Preferences.
# DW_NOISE (regex) overrides the list of chatty domains to ignore.
# Works with macOS's bash 3.2.
set -u
DIR="${TMPDIR:-/tmp}/defaults-watch"
NOISE="${DW_NOISE:-com\.apple\.(xpc\.activity2|spotlight|knowledge-agent|ContextStoreAgent|AddressBook|CallHistorySyncHelper|cloudd|commerce|iCal|identityservicesd|ids\.deviceproperties|imagent|madrid|mediaanalysisd|mobiletimer|NewDeviceOutreach|photolibraryd|proactive|routined|security|sharingd|stocks|suggestions|tipsd|triald|UserNotifications|appstored|biomesyncd|dataaccess|DuetExpertCenter|homed|GEO|corespotlightui|amp\.mediasharingd|passd|remindd|bird)}"

list() { tr ',' '\n' | sed 's/^ *//' | grep -v '^$'; }

dump() {
  rm -rf "$1"; mkdir -p "$1/user" "$1/host" "$1/sys"
  touch "$1/stamp"
  { defaults domains 2>/dev/null | list; echo NSGlobalDomain; } | sort -u | while IFS= read -r d; do
    defaults read "$d" > "$1/user/$d" 2>/dev/null
  done
  { defaults -currentHost domains 2>/dev/null | list; echo NSGlobalDomain; } | sort -u | while IFS= read -r d; do
    defaults -currentHost read "$d" > "$1/host/$d" 2>/dev/null
  done
  for p in /Library/Preferences/*.plist; do
    [ -r "$p" ] && defaults read "$p" > "$1/sys/$(basename "$p" .plist)" 2>/dev/null
  done
  find "$1" -type f -size 0 -delete
}

# top-level keys whose value block differs between two `defaults read` dumps
changed_keys() {
  awk '
    FNR == 1 { f++ }
    /^    [^ )}]/ { k = substr($0, 5); if (k ~ /^"/) { sub(/^"/, "", k); sub(/".*/, "", k) } else sub(/[ =].*/, "", k) }
    /^    / { blk[f, k] = blk[f, k] $0 "\n"; seen[k] = 1 }
    END { for (k in seen) if (blk[1, k] != blk[2, k]) print k }
  ' "$1" "$2" | sort
}

# nix value for a key, from its type
nixval() { # scope domain key
  local rd="defaults"; [ "$1" = host ] && rd="defaults -currentHost"
  local dom="$2"; [ "$1" = sys ] && dom="/Library/Preferences/$2"
  local t v
  t=$($rd read-type "$dom" "$3" 2>/dev/null | sed 's/^Type is //')
  v=$($rd read "$dom" "$3" 2>/dev/null)
  case "$t" in
    boolean) [ "$v" = 1 ] && echo true || echo false ;;
    integer|float) echo "$v" ;;
    string) printf '"%s"' "$(printf '%s' "$v" | sed 's/\\/\\\\/g; s/"/\\"/g')" ;;
    "") echo "__REMOVED__" ;;
    *) echo "__COMPLEX__ $t" ;;
  esac
}

case "${1:-}" in
  snap)
    echo "Snapshotting preferences..."
    dump "$DIR/before"
    echo "Done ($(find "$DIR/before" -type f | wc -l | tr -d ' ') domains). Change one setting, close the pane, then run: $0 diff"
    ;;
  diff)
    [ -d "$DIR/before" ] || { echo "No snapshot. Run: $0 snap"; exit 1; }
    sleep 1   # let cfprefsd flush
    dump "$DIR/after"
    found=0
    for scope in user host sys; do
      while IFS= read -r f; do
        printf '%s' "$f" | grep -Eq "^($NOISE)" && continue
        b="$DIR/before/$scope/$f"; a="$DIR/after/$scope/$f"
        [ -f "$b" ] || b=/dev/null; [ -f "$a" ] || a=/dev/null
        cmp -s "$b" "$a" && continue
        found=1
        echo "================ $f  [$scope]"
        diff -u "$b" "$a" | tail -n +3 | grep -E '^[+-]' | head -40
        # top-level keys are the 4-space-indented entries in `defaults read` output
        keys=$(changed_keys "$b" "$a")
        [ -n "$keys" ] || continue
        echo "---- suggested Nix (prefer a native system.defaults.* option if nix-darwin has one)"
        echo "$keys" | while IFS= read -r k; do
          v=$(nixval "$scope" "$f" "$k")
          case "$v" in
            __REMOVED__) echo "# key removed: \"$k\"" ; continue ;;
            __COMPLEX__*) echo "# \"$k\" is ${v#__COMPLEX__ } — copy the structure from the diff above"; continue ;;
          esac
          case "$scope" in
            user) echo "system.defaults.CustomUserPreferences.\"$f\".\"$k\" = $v;" ;;
            sys)  echo "system.defaults.CustomSystemPreferences.\"$f\".\"$k\" = $v;" ;;
            host) echo "# currentHost (no nix-darwin option): defaults -currentHost write $f \"$k\" ... in system.activationScripts.postActivation  (value: $v)" ;;
          esac
        done
      done < <( (ls "$DIR/before/$scope"; ls "$DIR/after/$scope") 2>/dev/null | sort -u)
    done
    [ "$found" = 1 ] || echo "No preference changes found (setting may live in a file — see below)."
    echo
    echo "================ other files modified since the snapshot"
    find "$HOME/Library/Preferences" "$HOME/Library/Application Support" "$HOME/.config" \
         -newer "$DIR/before/stamp" -type f 2>/dev/null \
      | grep -Ev '/(Caches?|Logs?|CrashReporter|Cookies|IndexedDB|Service Worker|GPUCache|Code Cache|Session Storage|Local Storage|blob_storage|WebKit)/|\.(log|db-wal|db-shm|sqlite-wal|sqlite-shm|ldb|lock)$|/Preferences/.*\.plist$' \
      | sed "s#$HOME/#~/#" | head -40
    ;;
  *) sed -n '2,12p' "$0"; exit 1 ;;
esac
