#!/bin/zsh

# シンボリックリンク
ln -sf ~/works/dotfiles/.zshrc ~/.zshrc
ln -sf ~/works/dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/works/dotfiles/starship.toml ~/.config/starship.toml
ln -sf ~/works/dotfiles/hammerspoon ~/.hammerspoon
ln -sf ~/works/dotfiles/vscodium/settings.json ~/.vscode/settings.json

source ~/.zshrc
