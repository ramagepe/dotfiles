# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"
source ~/.aliases

# Secretos locales de esta máquina. Nunca se commitea: ignorado por ~/.gitignore.
[ -f "$HOME/.secrets" ] && . "$HOME/.secrets"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# nvm ya no se carga: node lo maneja mise (ver ~/.config/mise/config.toml), que
# es tambien el motivo del `set +h` que hace Omarchy en su bash/shell. Cargar
# nvm ademas sourceaba 4000 lineas por terminal y su `hash -r` fallaba con
# "bash: hash: hashing disabled". Las versiones viejas siguen en
# ~/.config/nvm/versions/node/; para usarlas: . "$HOME/.config/nvm/nvm.sh"

# add Pulumi to the PATH
export PATH=$PATH:/home/ramage/.pulumi/bin

eval "$(direnv hook bash)"
export PATH="$HOME/.local/bin:$PATH"
export ANDROID_HOME=$HOME/Android/Sdk

# opencode
export PATH=/home/ramage/.opencode/bin:$PATH

. "$HOME/.local/share/../bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/ramage/.lmstudio/bin"
# End of LM Studio CLI section

# --- tmux pane border color based on directory (Aura theme palette) ---
_tmux_update_border() {
  [ -z "$TMUX" ] && return

  local accent
  case "$PWD" in
    */code/tcg|*/code/tcg/*)
      accent="#8BE9FD"  # cyan/green
      ;;
    */code/instacheck|*/code/instacheck/*)
      accent="#CBC3E3"  # lavanda
      ;;
    *)
      accent="#FFAFCC"  # pink/red
      ;;
  esac

  tmux set -p pane-active-border-style "fg=$accent"
}

PROMPT_COMMAND="_tmux_update_border${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

export PATH="/home/ramage/go/bin:$PATH"

# Android SDK (ANDROID_HOME already set above)
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_AVD_HOME="$HOME/.config/.android/avd"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# mise — per-project tool versions via .mise.toml (sets JAVA_HOME, etc.)
eval "$(mise activate bash)"
export PATH=$PATH:$HOME/.maestro/bin
