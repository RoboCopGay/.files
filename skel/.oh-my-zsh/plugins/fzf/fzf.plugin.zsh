# Setup fzf
# ---------
if [[ ! "$PATH" == */home/plankiton/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/plankiton/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/plankiton/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/plankiton/.fzf/shell/key-bindings.zsh"
