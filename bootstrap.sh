#!/usr/bin/env bash
# dotfiles セットアップ。何度実行しても同じ結果になる（冪等）。
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh git claude herdr starship hammerspoon vscode)

echo "==> Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# 一部のパッケージ（sudo が必要な cask など）が失敗してもリンク作成は続行する
brew bundle --file="$DOTFILES/Brewfile" || echo "⚠ 一部のパッケージのインストールに失敗しました。後で手動で確認してください"

echo "==> シンボリックリンク (stow)"
# stow がディレクトリごとリンクする（tree folding）のを防ぐ。
# 特に ~/.claude はセッション履歴などのランタイム状態を持つため実ディレクトリのまま保つ。
mkdir -p "$HOME/.claude" "$HOME/.config" "$HOME/.config/herdr" "$HOME/.vscode" "$HOME/.hammerspoon"

stow --dir="$DOTFILES" --target="$HOME" --restow "${PACKAGES[@]}"

echo "==> 完了。新しい設定を読み込むには: exec \$SHELL -l"
