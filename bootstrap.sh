#!/usr/bin/env bash
# dotfiles セットアップ。何度実行しても同じ結果になる（冪等）。
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh git claude agents herdr starship hammerspoon vscode)

echo "==> Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # インストール直後のシェルには brew が PATH に入っていないため、ここで読み込む
  for prefix in /opt/homebrew /usr/local; do
    [ -x "$prefix/bin/brew" ] && eval "$("$prefix/bin/brew" shellenv)"
  done
fi
# 一部のパッケージ（sudo が必要な cask など）が失敗してもリンク作成は続行する
brew bundle --file="$DOTFILES/Brewfile" || echo "⚠ 一部のパッケージのインストールに失敗しました。後で手動で確認してください"

echo "==> シンボリックリンク (stow)"
if ! command -v stow >/dev/null 2>&1; then
  echo "✗ stow がありません。brew install stow を実行してから再試行してください" >&2
  exit 1
fi

# stow がディレクトリごとリンクする（tree folding）のを防ぐ。
# 特に ~/.claude はセッション履歴などのランタイム状態を持つため実ディレクトリのまま保つ。
mkdir -p "$HOME/.agents" "$HOME/.claude" "$HOME/.config" "$HOME/.config/herdr" "$HOME/.vscode" "$HOME/.hammerspoon"

stow --dir="$DOTFILES" --target="$HOME" --restow "${PACKAGES[@]}"

# Claude Code はスキルを ~/.claude/skills から読む。実体は ~/.agents/skills（stow 管理）。
ln -sfn "$HOME/.agents/skills" "$HOME/.claude/skills"

echo "==> 完了。新しい設定を読み込むには: exec \$SHELL -l"
