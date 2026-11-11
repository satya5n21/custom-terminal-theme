#!/usr/bin/env bash
# custom-terminal-theme v1 - macOS installer (zsh / bash)
#
#   bash install.sh                  install for the shell you are using
#   bash install.sh --shell zsh      pick the shell explicitly (bash | zsh)
#   bash install.sh --name "Ada"     name shown in the greeting
#   bash install.sh --uninstall      remove the theme again
#
# What it does: copies terminal-theme.sh to ~/.config/custom-terminal-theme/
# and adds a small marked block to ~/.zshrc (or ~/.bash_profile) that sources it.
# Your rc file is backed up first. Running it again just updates the block.
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/terminal-theme.sh"
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/custom-terminal-theme"
DEST="$DEST_DIR/terminal-theme.sh"
BEGIN="# >>> custom-terminal-theme >>>"
END="# <<< custom-terminal-theme <<<"

SHELL_NAME=""
NAME=""
UNINSTALL=0

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --shell)     [ $# -ge 2 ] || die "--shell needs a value (bash or zsh)"; SHELL_NAME="$2"; shift 2 ;;
    --name)      [ $# -ge 2 ] || die "--name needs a value"; NAME="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h | --help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)           die "unknown option: $1 (try --help)" ;;
  esac
done

[ -n "$SHELL_NAME" ] || SHELL_NAME="$(basename "${SHELL:-zsh}")"
case "$SHELL_NAME" in
  bash) RC="$HOME/.bash_profile" ;;  # Terminal.app opens login shells
  zsh)  RC="${ZDOTDIR:-$HOME}/.zshrc" ;;
  *)    die "unsupported shell '$SHELL_NAME'. Supported: bash, zsh (use --shell to choose)." ;;
esac

# Print a file with the theme block (and the blank line before it) removed.
strip_block() {
  awk -v b="$BEGIN" -v e="$END" '
    $0 == b { skip = 1; held = 0; next }
    skip && $0 == e { skip = 0; next }
    skip { next }
    { if (held) { print ""; held = 0 }
      if ($0 == "") held = 1; else print }
    END { if (held) print "" }
  ' "$1"
}

# Write stdin over $RC in place (keeps symlinked dotfiles intact).
write_rc() { cat > "$RC"; }

if [ "$UNINSTALL" = 1 ]; then
  if [ -f "$RC" ] && grep -qF "$BEGIN" "$RC"; then
    tmp="$(mktemp)"; strip_block "$RC" > "$tmp"; write_rc < "$tmp"; rm -f "$tmp"
    echo "Removed theme block from $RC"
  else
    echo "No theme block found in $RC"
  fi
  rm -f "$DEST"; rmdir "$DEST_DIR" 2>/dev/null || true
  echo "Done. Open a new terminal to see the change."
  exit 0
fi

[ -f "$SRC" ] || die "can't find $SRC - run this script from the v1/macos folder."

mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST"

touch "$RC"
backup="$RC.ctt-backup-$(date +%Y%m%d-%H%M%S)"
cp "$RC" "$backup"

tmp="$(mktemp)"
{
  strip_block "$RC"
  printf '\n%s\n' "$BEGIN"
  if [ -n "$NAME" ]; then
    printf "export THEME_NAME='%s'\n" "$(printf '%s' "$NAME" | sed "s/'/'\\\\''/g")"
  fi
  printf '[ -r "%s" ] && . "%s"\n' "$DEST" "$DEST"
  printf '%s\n' "$END"
} > "$tmp"
write_rc < "$tmp"
rm -f "$tmp"

echo "Installed for $SHELL_NAME."
echo "  theme : $DEST"
echo "  rc    : $RC  (backup: $backup)"
echo "Open a new terminal (or run: source \"$RC\") to see it."
