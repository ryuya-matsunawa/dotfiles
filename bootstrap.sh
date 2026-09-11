#!/usr/bin/env bash
# dotfiles セットアップ。何度実行しても同じ結果になる（冪等）。
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh git claude starship hammerspoon vscode)

echo "==> Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle --file="$DOTFILES/Brewfile"

echo "==> シンボリックリンク (stow)"
# stow がディレクトリごとリンクする（tree folding）のを防ぐ。
# 特に ~/.claude はセッション履歴などのランタイム状態を持つため実ディレクトリのまま保つ。
mkdir -p "$HOME/.claude" "$HOME/.config" "$HOME/.vscode" "$HOME/.hammerspoon"

stow --dir="$DOTFILES" --target="$HOME" --restow "${PACKAGES[@]}"

echo "==> 完了。新しい設定を読み込むには: exec \$SHELL -l"
