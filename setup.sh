#!/bin/bash

if [[ $(command -v brew) == "" ]]; then
  echo "Installing Hombrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  if [[ "$(command -v brew)" != "" || "$OSTYPE" == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew update
else
  echo "Updating Homebrew"
  brew update
fi

brew install gettext cmake unzip curl wget nodejs npm tmux ffind ripgrep jq stow vivid bat eza zoxide git-delta

mkdir -p ~/.config

(
  git clone -b v0.10.0 https://github.com/neovim/neovim
  cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  cd ../
  rm -rf neovim
)

(
  git clone https://github.com/catppuccin/zsh-syntax-highlighting.git ~/.zsh-catpuccin
)

(
  mkdir -p "$(bat --config-dir)/themes"
  wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
  bat cache --build
)

(
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --update-rc
)

git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

stow -v --adopt -t $HOME home
~/.config/tmux/plugins/tpm/bin/install_plugins

chsh -s $(which zsh)
zsh -l
