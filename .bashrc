# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc
source ~/.aliases

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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

