#!/bin/zsh

# シンボリックリンク
ln -sf ~/works/dotfiles/.zshrc ~/.zshrc
ln -sf ~/works/dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/works/dotfiles/starship/starship.toml ~/.config/starship.toml
ln -sf ~/works/dotfiles/hammerspoon ~/.hammerspoon
ln -sf ~/works/dotfiles/vscode/settings.json ~/.vscode/settings.json

# Claude Code（ランタイム状態や環境依存の settings.json は管理対象外）
mkdir -p ~/.claude
ln -sf ~/works/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sfn ~/works/dotfiles/claude/rules ~/.claude/rules
ln -sfn ~/works/dotfiles/claude/hooks ~/.claude/hooks

source ~/.zshrc
