# shellcheck shell=bash
# ---------------------------------------------------------------------------
# custom-terminal-theme v1 - macOS (zsh and bash)
#
# Gradient greeting banner, date/time, random dev quote and a two-line
# prompt with the current git branch. Same look as the Windows PowerShell
# profile. Source this file from ~/.zshrc (or ~/.bash_profile); install.sh does it.
#
# Optional settings (set before this file is sourced):
#   THEME_NAME       name shown in the greeting (default: your login name)
#   THEME_TRUECOLOR  1 = force 24-bit colour, 0 = force 256-colour fallback
# ---------------------------------------------------------------------------

# Only run in interactive shells (never break scp, ssh host cmd, scripts...)
case $- in *i*) ;; *) return 0 ;; esac

THEME_NAME="${THEME_NAME:-$(id -un)}"

# --- colour mode ----------------------------------------------------------
_ctt_truecolor=0
case "${THEME_TRUECOLOR:-${COLORTERM:-}}" in
  1 | truecolor | 24bit) _ctt_truecolor=1 ;;
esac
# Note: Apple's Terminal.app has no 24-bit colour, so it gets the 256-colour
# fallback automatically. iTerm2, WezTerm, Ghostty, Warp, VS Code etc. set
# COLORTERM=truecolor and get the full gradient.

# --- gradient text helper (cyan -> purple) --------------------------------
_ctt_gradient() {
  local text="$1" len i=0 d ch r g b
  len=${#text}
  d=$((len > 1 ? len - 1 : 1))
  while [ "$i" -lt "$len" ]; do
    ch="${text:$i:1}"
    r=$((180 * i / d))
    g=$((230 - 150 * i / d))
    b=255
    if [ "$_ctt_truecolor" = 1 ]; then
      printf '\033[38;2;%d;%d;%dm%s' "$r" "$g" "$b" "$ch"
    else
      # 256-colour fallback: map to the 6x6x6 colour cube
      printf '\033[38;5;%dm%s' \
        $((16 + 36 * ((r * 5 + 127) / 255) + 6 * ((g * 5 + 127) / 255) + (b * 5 + 127) / 255)) "$ch"
    fi
    i=$((i + 1))
  done
  printf '\033[0m\n'
}

# --- system info ----------------------------------------------------------
_ctt_uptime() {
  local boot s
  boot=$(sysctl -n kern.boottime 2>/dev/null | sed 's/.*sec = \([0-9]*\).*/\1/')
  [ -n "$boot" ] || return 0
  s=$(($(date +%s) - boot))
  printf '%dd %dh %dm' $((s / 86400)) $((s % 86400 / 3600)) $((s % 3600 / 60))
}

# --- banner ---------------------------------------------------------------
clear

hour=$((10#$(date +%H)))
if [ "$hour" -lt 12 ]; then
  _ctt_greet="Good morning"
elif [ "$hour" -lt 18 ]; then
  _ctt_greet="Good afternoon"
else
  _ctt_greet="Good evening"
fi
unset hour

printf '\n'
_ctt_gradient "+==============================================+"
_ctt_gradient "   >>>  $_ctt_greet, $THEME_NAME"
_ctt_gradient "+==============================================+"
printf '  \033[90mDATE:\033[0m %s   \033[90mTIME:\033[0m %s\n' "$(date '+%A, %d %b %Y')" "$(date '+%H:%M')"
# printf '  \033[90mHOST:\033[0m %s   \033[90mUP:\033[0m %s   \033[90mSHELL:\033[0m %s\n' "$(scutil --get ComputerName 2>/dev/null || hostname)" "$(_ctt_uptime)" "${SHELL##*/}"

# --- random dev quote -----------------------------------------------------
case $((RANDOM % 5)) in
  0) _ctt_quote="Ship it. Then make it better." ;;
  1) _ctt_quote="Make it work, make it right, make it fast." ;;
  2) _ctt_quote="Build in public. Learn in public." ;;
  3) _ctt_quote="Talk is cheap. Show me the code." ;;
  *) _ctt_quote="Stay curious. Look up." ;;
esac
printf '  \033[3m\033[35m"%s"\033[0m\n\n' "$_ctt_quote"

unset -f _ctt_gradient
unset _ctt_greet _ctt_quote

# --- two-line prompt with git branch --------------------------------------
# Runs before each prompt; stores " (git:<branch>)" (or nothing) in _CTT_GIT.
_ctt_precmd() {
  local branch
  branch=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # zsh expands % in prompts, so double it; bash is unaffected by this var.
    if [ -n "${ZSH_VERSION:-}" ]; then branch="${branch//\%/%%}"; fi
    _CTT_GIT=" (git:$branch)"
  else
    _CTT_GIT=""
  fi
}

if [ -n "${ZSH_VERSION:-}" ]; then
  # ---- zsh ----
  setopt prompt_subst
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _ctt_precmd
  PROMPT=$'%{\e[90m%}+-- %{\e[36m%}%D{%H:%M} %{\e[32m%}%~%{\e[35m%}${_CTT_GIT}%{\e[0m%}\n%{\e[90m%}\'-%{\e[96m%}> %{\e[0m%}'
elif [ -n "${BASH_VERSION:-}" ]; then
  # ---- bash ----
  # ${_CTT_GIT} is expanded when the prompt is drawn, so branch names are
  # never interpreted as prompt escapes.
  PS1='\[\e[90m\]+-- \[\e[36m\]\A \[\e[32m\]\w\[\e[35m\]${_CTT_GIT}\[\e[0m\]\n\[\e[90m\]'"'"'-\[\e[96m\]> \[\e[0m\]'
  # Append to PROMPT_COMMAND without clobbering what is already there
  # (bash 5.1+ allows it to be an array).
  case "$(declare -p PROMPT_COMMAND 2>/dev/null)" in
    "declare -a"*)
      case " ${PROMPT_COMMAND[*]} " in *" _ctt_precmd "*) ;; *) PROMPT_COMMAND+=(_ctt_precmd) ;; esac
      ;;
    *)
      case ";${PROMPT_COMMAND:-};" in
        *";_ctt_precmd;"*) ;;
        *) PROMPT_COMMAND="_ctt_precmd${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
      esac
      ;;
  esac
fi
