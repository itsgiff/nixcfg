#!/usr/bin/env bash
# ~/.nixcfg/scripts/ai-audit.sh
# Read-only inventory of AI clients on this machine (macbook or x1), for
# deciding what nixcfg should declare: binaries and where they came from,
# desktop apps, config folders (Claude Code, Codex, Claude Desktop and the
# rest), instruction files, MCP servers, and every skill found under $HOME
# with which client loads it. Run it on both machines and compare the two
# skills.tsv / files.tsv files.
#
# Usage: scripts/ai-audit.sh [outdir]   (default: ~/nixcfg-ai-audit-<host>-YYYYmmdd-HHMM)
# Writes report.md, skills.tsv, files.tsv, plus <outdir>.tgz to attach.
# Needs: jq. Works with macOS's bash 3.2. Changes nothing.
# Secrets: auth/credential files are never read; values whose key looks like
# a token, key, secret, password or auth, and everything under env/headers,
# are printed as <redacted>. Still skim report.md before sharing it.
set -u

HOST="${HOSTNAME_OVERRIDE:-$(hostname -s 2>/dev/null || hostname)}"
OUT="${1:-$HOME/nixcfg-ai-audit-$HOST-$(date +%Y%m%d-%H%M)}"
mkdir -p "$OUT"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
R="$OUT/report.md"; : > "$R"
have() { command -v "$1" >/dev/null 2>&1; }
have jq || { echo "jq is required"; exit 1; }
case "$(uname -s)" in Darwin) MAC=1 ;; *) MAC=0 ;; esac
if have sha256sum; then sha() { sha256sum "$@" | cut -c1-12; }; else sha() { shasum -a 256 "$@" | cut -c1-12; }; fi
say() { printf '%s\n' "$*" >> "$R"; }
h() { say ""; say "## $*"; say ""; }
code() { say '```'; cat >> "$R"; say '```'; }
mtime() { if [ "$MAC" = 1 ]; then /usr/bin/stat -f %Sm -t %F "$1" 2>/dev/null || echo "?"; else date -r "$1" +%F 2>/dev/null || echo "?"; fi; }
rel() { case "$1" in "$HOME"/*) echo "~/${1#"$HOME"/}" ;; *) echo "$1" ;; esac; }
# How a path is managed: nix (Home Manager link), link -> elsewhere, or plain
linkinfo() {
  t=$(readlink -f "$1" 2>/dev/null || echo "$1")
  if [ "$t" = "$1" ]; then echo "plain"
  else case "$t" in /nix/store/*) echo "nix" ;; *) echo "link->$(rel "$t")" ;; esac; fi
}
# Where a binary came from
source_of() {
  case "$1" in
    /nix/store/*|/etc/profiles/*|/run/current-system/*|*/.nix-profile/*) echo "nix" ;;
    /opt/homebrew/*|/usr/local/Cellar/*|/usr/local/Caskroom/*|*/Caskroom/*) echo "homebrew" ;;
    *node_modules*|*/fnm*|*/.npm*|*/.nvm/*) echo "npm" ;;
    "$HOME"/.local/*|"$HOME"/.claude/*|"$HOME"/.codex/*) echo "self-installer (~/.local etc.)" ;;
    /Applications/*) echo "app bundle" ;;
    *) echo "other" ;;
  esac
}
# --version with a 5 s limit (no `timeout` on macOS)
ver() {
  "$1" --version </dev/null >"$TMP/v" 2>/dev/null & p=$!
  i=0; while kill -0 "$p" 2>/dev/null && [ $i -lt 50 ]; do sleep 0.1; i=$((i+1)); done
  kill "$p" 2>/dev/null; wait "$p" 2>/dev/null
  head -1 "$TMP/v" | tr -d '\r' | cut -c1-60
}
# JSON with secrets blanked
JQ_REDACT='def r: if type=="object" then with_entries(
    if (.key|test("^(env|headers)$")) and (.value|type=="object") then .value |= map_values("<redacted>")
    elif (.key|test("token|key|secret|password|passwd|auth|credential|bearer|cookie";"i")) and (.value|type=="string" or type=="number") then .value="<redacted>"
    else .value |= r end)
  elif type=="array" then map(r) else . end; r'
redact_json() { jq "$JQ_REDACT" "$1" 2>/dev/null || echo "(not valid JSON)"; }
# TOML with secrets blanked (everything in [*.env] / [*.headers] tables too)
redact_toml() {
  awk '
    /^[[:space:]]*\[/ { sec = tolower($0); print; next }
    /^[[:space:]]*[A-Za-z0-9_."-]+[[:space:]]*=/ {
      k = $0; sub(/=.*/, "", k); lk = tolower(k)
      if (sec ~ /\.(env|headers)\]/ || lk ~ /token|key|secret|password|auth|bearer|cookie/) { print k "= \"<redacted>\""; next }
      if (lk ~ /^[[:space:]]*(env|headers|http_headers)[[:space:]]*$/) { print k "= { <redacted> }"; next }
    }
    { print }' "$1"
}

PAT='claude|codex|chatgpt|openai|perplexity|comet|gemini|cursor|ollama|lm ?studio|copilot|opencode|aider|goose|windsurf|jan|msty|anythingllm'
say "# AI client inventory: $HOST ($(uname -sm)), $(date '+%Y-%m-%d %H:%M')"
say ""
say "Read-only. Secrets redacted. Companion files: skills.tsv, files.tsv."
echo "Writing report to $OUT"

# ------------------------------------------------------------ 1. binaries
h "1. Command-line binaries"
say "| command | path | resolves to | source | version |"
say "|---|---|---|---|---|"
for c in claude codex claude-desktop gemini opencode aider ollama llm cursor cursor-agent copilot goose amp crush chatgpt perplexity lms; do
  for p in $(type -ap "$c" 2>/dev/null | awk '!s[$0]++'); do
    real=$(readlink -f "$p" 2>/dev/null || echo "$p")
    case "$c" in claude-desktop|chatgpt|perplexity|cursor) v="(not run: GUI)" ;; *) v=$(ver "$p") ;; esac
    say "| $c | $(rel "$p") | $(rel "$real") | $(source_of "$real") | ${v:-?} |"
  done
done
say ""
say "First match in each command's list is the one that runs."

h "2. Package managers (AI-related entries)"
{
  if have npm; then echo "# npm -g"; npm ls -g --depth=0 2>/dev/null | grep -iE "$PAT" || echo "(none)"; fi
  if have brew; then
    echo "# brew formulae"; brew list --formula -1 2>/dev/null | grep -iE "$PAT" || echo "(none)"
    echo "# brew casks";    brew list --cask -1 2>/dev/null    | grep -iE "$PAT" || echo "(none)"
  fi
  if have uv;   then echo "# uv tool";  uv tool list 2>/dev/null | grep -iE "$PAT" || echo "(none)"; fi
  if have pipx; then echo "# pipx";     pipx list --short 2>/dev/null | grep -iE "$PAT" || echo "(none)"; fi
  if have nix;  then echo "# nix profile"; nix profile list 2>/dev/null | grep -iE "$PAT" || echo "(none)"; fi
  if have flatpak; then echo "# flatpak"; flatpak list --app --columns=application 2>/dev/null | grep -iE "$PAT" || echo "(none)"; fi
  echo "# ~/.local/bin"; ls -l "$HOME/.local/bin" 2>/dev/null | grep -iE "$PAT" || echo "(none)"
} | code

# ------------------------------------------------------------ 3. apps
h "3. Desktop apps and launchers"
{
  if [ $MAC = 1 ]; then
    for a in /Applications/*.app "$HOME"/Applications/*.app; do
      [ -d "$a" ] || continue
      echo "$a" | grep -qiE "$PAT" || continue
      v=$(defaults read "$a/Contents/Info" CFBundleShortVersionString 2>/dev/null)
      id=$(defaults read "$a/Contents/Info" CFBundleIdentifier 2>/dev/null)
      echo "$(rel "$a")  $v  $id"
    done
  else
    for d in "$HOME/.local/share/applications" "/etc/profiles/per-user/${USER:-$(id -un)}/share/applications" /run/current-system/sw/share/applications; do
      for f in "$d"/*.desktop; do
        [ -e "$f" ] || continue
        grep -qiE "^(Name|Exec)=.*($PAT)" "$f" || continue
        echo "$(rel "$f")  [$(linkinfo "$f")]  $(grep -m1 '^Exec=' "$f" | cut -c1-110)"
      done
    done
  fi
} | code

# ------------------------------------------------------------ 4. config folders
# Client folders: every file except the noise below, with how it's managed.
NOISE='/(projects|todos|shell-snapshots|statsig|ide|file-history|session-env|debug|telemetry|sessions|log|logs|cache|Cache|Code Cache|GPUCache|DawnCache|DawnGraphiteCache|DawnWebGPUCache|IndexedDB|Local Storage|Session Storage|WebStorage|blob_storage|Crashpad|Service Worker|Shared Dictionary|VideoDecodeStats|vm_bundles|claude-code-vm|sentry|Network|Partitions|Dictionaries|node_modules|\.git|archived_sessions|history|tmp)(/|$)|history\.jsonl$'
SECRET_FILE='(auth\.json|\.credentials\.json|credentials|.*token.*|.*\.key|Cookies.*|.*\.pem)$'
if [ $MAC = 1 ]; then AS="$HOME/Library/Application Support"
  DIRS="$HOME/.claude|$HOME/.codex|$HOME/.agents|$HOME/.gemini|$HOME/.cursor|$HOME/.config/opencode|$HOME/.config/mcp|$HOME/.ollama|$AS/Claude|$AS/Claude-3p|$AS/com.openai.chat|$AS/ChatGPT|$AS/Codex|$AS/Perplexity|$AS/ai.perplexity.mac|$AS/Comet"
else
  DIRS="$HOME/.claude|$HOME/.codex|$HOME/.agents|$HOME/.gemini|$HOME/.cursor|$HOME/.config/opencode|$HOME/.config/mcp|$HOME/.ollama|$HOME/.config/Claude|$HOME/.config/ChatGPT|$HOME/.config/Codex"
fi
printf 'file\tmanaged\tbytes\tsha\tmodified\n' > "$OUT/files.tsv"
h "4. Config folders"
say "Every file in each folder except caches, sessions, history and logs; \`nix\` = Home Manager link, \`plain\` = unmanaged. Full list with hashes in files.tsv."
OLDIFS=$IFS; IFS='|'
for d in $DIRS; do
  IFS=$OLDIFS
  [ -e "$d" ] || continue
  say ""; say "### $(rel "$d")  [$(linkinfo "$d")]"
  find -L "$d" \( -type d -o -type f \) 2>/dev/null | grep -vE "$NOISE" | LC_ALL=C sort | while IFS= read -r f; do
    [ -f "$f" ] || continue
    b=$(wc -c < "$f" | tr -d ' ')
    if echo "$f" | grep -qiE "$SECRET_FILE"; then s="(secret, not read)"; else s=$(sha "$f"); fi
    printf '%s\t%s\t%s\t%s\t%s\n' "$(rel "$f")" "$(linkinfo "$f")" "$b" "$s" "$(mtime "$f")" >> "$OUT/files.tsv"
    echo "$(rel "$f")  [$(linkinfo "$f")] ${b}B $(mtime "$f")"
  done > "$TMP/list"
  n=$(wc -l < "$TMP/list" | tr -d ' ')
  if [ "$n" -gt 150 ]; then head -150 "$TMP/list" | code; say "($n files, first 150 shown; all in files.tsv)"
  else code < "$TMP/list"; fi
  IFS='|'
done
IFS=$OLDIFS

# ------------------------------------------------------------ 5. key configs
h "5. Key config files (redacted)"
show_json() { [ -f "$1" ] || return 0; say "### $(rel "$1")  [$(linkinfo "$1")]"; redact_json "$1" | code; say ""; }
show_toml() { [ -f "$1" ] || return 0; say "### $(rel "$1")  [$(linkinfo "$1")]"; redact_toml "$1" | code; say ""; }
show_json "$HOME/.claude/settings.json"
show_json "$HOME/.claude/settings.local.json"
show_json "$HOME/.claude/plugins/installed_plugins.json"
show_json "$HOME/.claude/plugins/known_marketplaces.json"
show_toml "$HOME/.codex/config.toml"
show_json "$HOME/.config/mcp/mcp.json"
if [ $MAC = 1 ]; then show_json "$AS/Claude/claude_desktop_config.json"; show_json "$AS/Claude/config.json"
else show_json "$HOME/.config/Claude/claude_desktop_config.json"; show_json "$HOME/.config/Claude/config.json"; fi
if [ -f "$HOME/.claude.json" ]; then
  say "### ~/.claude.json (Claude Code state; only key names and MCP server names)"
  jq '{top_level_keys: keys,
       user_mcpServers: ((.mcpServers // {}) | keys),
       projects: ((.projects // {}) | length),
       project_mcpServers: [ (.projects // {}) | to_entries[]
          | select((.value.mcpServers // {}) != {}) | {(.key): (.value.mcpServers | keys)} ]}' \
     "$HOME/.claude.json" 2>/dev/null | code
fi

# ------------------------------------------------------------ 6. instructions
h "6. Instruction files"
for f in "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "$HOME/.config/AGENTS.md" "$HOME/.gemini/GEMINI.md"; do
  [ -f "$f" ] || continue
  say "### $(rel "$f")  [$(linkinfo "$f")] $(wc -l < "$f" | tr -d ' ') lines, sha $(sha "$f")"
  code < "$f"; say ""
done

# ------------------------------------------------------------ 7. skills
# Every SKILL.md under $HOME (big and noisy folders skipped), plus the app
# folders above (Library is skipped by the general search on the Mac).
PRUNE_NAMES='.cache|.npm|node_modules|.git|.Trash|Trash|.cargo|.rustup|.m2|.gradle|.direnv|.vscode-server|vm_bundles|Cache|Code Cache|IndexedDB'
PRUNE_PATHS="$HOME/Library|$HOME/.nix-defexpr|$HOME/.nix-profile|$HOME/go|$HOME/Pictures|$HOME/Music|$HOME/Movies|$HOME/snap|$HOME/.vscode|$HOME/.local/state|$HOME/.local/share/Trash|$HOME/.mozilla|$HOME/.config/google-chrome|$HOME/.claude/projects|$HOME/.codex/sessions"
prune_args() { first=1; OLDIFS=$IFS; IFS='|'
  for n in $PRUNE_NAMES; do [ $first = 1 ] || printf '%s\0' -o; printf '%s\0' -name "$n"; first=0; done
  for n in $PRUNE_PATHS; do printf '%s\0' -o -path "$n"; done
  IFS=$OLDIFS; }
prune_args > "$TMP/prune"
# General search doesn't follow links (so it can't wander into NFS mounts);
# the clients' own skill folders are searched again following links, so
# linked skills (e.g. from Home Manager) are found too.
: > "$TMP/skillfiles"
xargs -0 sh -c 'exec find "$0" -maxdepth 12 \( -type d \( "$@" \) -prune \) -o -name SKILL.md \( -type f -o -type l \) -print' "$HOME" < "$TMP/prune" 2>/dev/null >> "$TMP/skillfiles"
linked="$HOME/.claude/skills|$HOME/.claude/plugins|$HOME/.codex/skills|$HOME/.agents/skills|$HOME/.gemini|$HOME/.config/opencode|$HOME/.config/Claude"
[ $MAC = 1 ] && linked="$linked|$AS/Claude|$AS/com.openai.chat|$AS/Codex|$AS/Perplexity"
OLDIFS=$IFS; IFS='|'
for root in $linked; do
  [ -d "$root" ] && find -L "$root" -maxdepth 8 \( -type d \( -name Cache -o -name 'Code Cache' -o -name IndexedDB -o -name vm_bundles -o -name node_modules -o -name .git \) -prune \) -o -type f -name SKILL.md -print 2>/dev/null >> "$TMP/skillfiles"
done
IFS=$OLDIFS
sort -u "$TMP/skillfiles" -o "$TMP/skillfiles"

client_of() {
  case "$1" in
    "$HOME"/.claude/skills/*)            echo "Claude Code|user" ;;
    "$HOME"/.claude/plugins/*)           echo "Claude Code|plugin" ;;
    "$HOME"/.codex/skills/.system/*)     echo "Codex|built-in" ;;
    "$HOME"/.codex/skills/*)             echo "Codex|user" ;;
    "$HOME"/.agents/skills/*)            echo "Codex (~/.agents)|user" ;;
    "$HOME"/.gemini/*)                   echo "Gemini CLI|user" ;;
    "$HOME"/.config/opencode/*)          echo "opencode|user" ;;
    *"/Application Support/Claude/"*|"$HOME"/.config/Claude/*) echo "Claude Desktop|app copy" ;;
    *"/com.openai.chat/"*|*"/Codex/"*)  echo "ChatGPT/Codex app|app copy" ;;
    */.claude/skills/*)                  echo "Claude Code|project" ;;
    */.codex/skills/*|*/.agents/skills/*) echo "Codex|project" ;;
    *)                                   echo "none?|loose" ;;
  esac
}
fm() { awk -v k="$2" 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit}
  grab && /^[[:space:]]+/ { sub(/^[[:space:]]+/, ""); v = v (v=="" ? "" : " ") $0; next }
  grab { exit }
  index($0, k":")==1 { v = $0; sub("^" k ":[[:space:]]*", "", v)
    if (v ~ /^[>|][-+]?$/) { v = ""; grab = 1; next } exit }
  END { gsub(/^["'\'']|["'\'']$/, "", v); print v }' "$1"; }
printf 'name\tclient\tscope\tpath\tmanaged\tfiles\tcontent_sha\tmodified\tdescription\n' > "$OUT/skills.tsv"
while IFS= read -r f; do
  d=$(dirname "$f")
  cs=$(cd "$d" && find -L . -type f ! -name .DS_Store 2>/dev/null | LC_ALL=C sort | while IFS= read -r x; do printf '%s %s\n' "$x" "$(sha "$x")"; done | sha)
  nf=$(find -L "$d" -type f ! -name .DS_Store 2>/dev/null | wc -l | tr -d ' ')
  cl=$(client_of "$d/")
  desc=$(fm "$f" description | tr '\t' ' ' | cut -c1-140)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(fm "$f" name)" "${cl%%|*}" "${cl#*|}" "$(rel "$d")" \
    "$(linkinfo "$d")" "$nf" "$cs" "$(mtime "$f")" "$desc" >> "$OUT/skills.tsv"
done < "$TMP/skillfiles"
# A loose copy that a client's skill links to is that skill's source, not a stray
awk -F'\t' -v OFS='\t' 'NR==FNR { if ($5 ~ /^link->/) src[substr($5, 7)] = $4; next }
  FNR > 1 && $3 == "loose" && ($4 in src) { $2 = "(source)"; $3 = "linked from " src[$4] } { print }' \
  "$OUT/skills.tsv" "$OUT/skills.tsv" > "$TMP/s.tsv" && mv "$TMP/s.tsv" "$OUT/skills.tsv"

h "7. Skills ($(($(wc -l < "$OUT/skills.tsv") - 1)) found)"
say "client/scope: which client loads it (\`loose\` = a SKILL.md no client looks at, e.g. a download or a source copy). content_sha covers every file in the skill folder, so the same value on both machines means identical skills."
say ""
say "| name | client | scope | path | managed | files | content_sha | modified |"
say "|---|---|---|---|---|---|---|---|"
tail -n +2 "$OUT/skills.tsv" | sort -t$'\t' -k2,2 -k3,3 -k1,1 | awk -F'\t' '{printf "| %s | %s | %s | %s | %s | %s | %s | %s |\n",$1,$2,$3,$4,$5,$6,$7,$8}' >> "$R"
say ""
say "Same content in more than one place on this machine:"
tail -n +2 "$OUT/skills.tsv" | awk -F'\t' '{n[$7]++; p[$7]=p[$7] "\n  " $4} END {for (s in n) if (n[s]>1) printf "%s:%s\n", s, p[s]}' | code

# ------------------------------------------------------------ 8. other agent files
h "8. Commands, agents, hooks, project-level files"
{
  echo "# user-level commands / agents / prompts / output styles / hooks"
  for d in "$HOME/.claude/commands" "$HOME/.claude/agents" "$HOME/.claude/output-styles" "$HOME/.claude/hooks" "$HOME/.codex/prompts" "$HOME/.codex/rules"; do
    [ -d "$d" ] && find -L "$d" -type f 2>/dev/null | while IFS= read -r f; do echo "$(rel "$f")  [$(linkinfo "$f")]"; done
  done
  echo; echo "# hooks and status line in settings.json"
  jq -r '(.hooks // {} | keys | map("hook: " + .) | .[]), (if .statusLine then "statusLine: \(.statusLine.command // .statusLine)" else empty end)' "$HOME/.claude/settings.json" 2>/dev/null
  echo; echo "# project-level files under \$HOME (CLAUDE.md, AGENTS.md, .claude/, .mcp.json, ...)"
  xargs -0 sh -c 'exec find "$0" -maxdepth 8 \( -type d \( "$@" \) -prune \) -o \( -name CLAUDE.md -o -name AGENTS.md -o -name GEMINI.md -o -name .mcp.json -o -name .cursorrules -o -path "*/.claude/settings*.json" -o -path "*/.claude/commands/*" -o -path "*/.claude/agents/*" \) -print' "$HOME" < "$TMP/prune" 2>/dev/null \
    | grep -vE "^$HOME/\.(claude|codex)/" | LC_ALL=C sort | while IFS= read -r f; do rel "$f"; done
} | code

# ------------------------------------------------------------ 9. env and leftovers
h "9. Environment variables and leftovers"
{
  echo "# exported AI-related variables (names only)"
  env | cut -d= -f1 | grep -E 'ANTHROPIC|OPENAI|CLAUDE|CODEX|PERPLEXITY|GEMINI|MCP|OLLAMA' | sort || true
  echo; echo "# fish config files that mention them (names only)"
  grep -rlE 'ANTHROPIC|OPENAI|CLAUDE_|CODEX_|PERPLEXITY|GEMINI' "$HOME/.config/fish" 2>/dev/null | while IFS= read -r f; do echo "$(rel "$f")  [$(linkinfo "$f")]"; done
  echo; echo "# *.hm-bak in the client folders"
  OLDIFS=$IFS; IFS='|'; for d in $DIRS; do [ -d "$d" ] && find "$d" -maxdepth 4 -name '*.hm-bak' 2>/dev/null; done; IFS=$OLDIFS
} | code

tar -czf "$OUT.tgz" -C "$(dirname "$OUT")" "$(basename "$OUT")"
echo "Done: $R"
echo "Attach: $OUT.tgz (skim report.md first)"
