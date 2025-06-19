export HISTORY_START_WITH_GLOBAL=true

# Utility to add to path without duplication
pathmunge() {
  if ! echo $PATH | /usr/bin/env grep -E -q "(^|:)$1($|:)"; then
    if [ "$2" = "after" ]; then
      PATH=$PATH:$1
    else
      PATH=$1:$PATH
    fi
  fi
}

# Utility to check for presence of binaries
require() {
  command -v "${1}" &>/dev/null && return 0
  printf 'Missing required application: %s\n' "${1}" >&2
  return 1
}

if [[ "$OSTYPE" == "linux-gnu"* && -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

[ -f ~/.lcl.zshenv ] && source ~/.lcl.zshenv

if [[ ! -v OVERRIDE_ZSH_CUSTOMIZATION ]]; then
  source ~/.zsh-catpuccin/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh
  export FZF_DEFAULT_OPTS=" \
      --color=bg+:#313244,bg:#0e0e1e,spinner:#f5e0dc,hl:#f38ba8 \
      --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
      --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

  export BAT_THEME="Catppuccin Mocha"
  export EZA_COLORS="$(vivid generate catppuccin-mocha)"
fi

pathmunge $HOME/local/bin
pathmunge $HOME/.local/bin
pathmunge $HOME/local/lib
CASE_SENSITIVE="true"

if [ -z "$(pgrep ssh-agent)" ]; then
    eval $(ssh-agent) >/dev/null 2>&1
    echo $SSH_AUTH_SOCK >~/.ssh/.agent_socket
else
    export SSH_AUTH_SOCK=$(cat ~/.ssh/.agent_socket)
fi

export VENV_HOME="$HOME/.virtualenvs"
[[ -d $VENV_HOME ]] || mkdir $VENV_HOME

lsvenv() {
  ls -1 $VENV_HOME
}

venv() {
  if [ $# -eq 0 ]; then
    echo "Please provide venv name"
  else
    source "$VENV_HOME/$1/bin/activate"
  fi
}

mkvenv() {
  if [ $# -eq 0 ]; then
    echo "Please provide venv name"
  else
    python3 -m venv $VENV_HOME/$1
  fi
}

rmvenv() {
  if [ $# -eq 0 ]; then
    echo "Please provide venv name"
  else
    rm -r $VENV_HOME/$1
  fi
}

export OLLAMA_API_BASE=http://127.0.0.1:11434

airun() {
  export OLLAMA_CONTEXT_LENGTH=8192 ollama serve
  aider --model ollama_chat/${1}
}
