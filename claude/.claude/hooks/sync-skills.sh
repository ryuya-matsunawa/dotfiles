#!/usr/bin/env bash
# Claude Code の SessionStart で走り、~/.agents 配下（スキル本体と .skill-lock.json）の
# 変更を dotfiles に取り込む。セッション開始を遅らせないよう、通信は必ず背景に回す。
set -uo pipefail

DOTFILES="$HOME/works/dotfiles"
LOG="${TMPDIR:-/tmp}/dotfiles-sync-skills.log"
exec >>"$LOG" 2>&1
echo "=== $(date '+%F %T') ==="

[ -d "$DOTFILES/.git" ] || exit 0
cd "$DOTFILES" || exit 0

# rebase / merge の途中に割り込むと状態が壊れるため何もしない
if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ] || [ -f .git/MERGE_HEAD ]; then
  echo "skip: rebase/merge 進行中"
  exit 0
fi

# agents/ 以外に手を触れないよう、ステージングもコミットも pathspec で限定する
git add -A -- agents
if git diff --cached --quiet -- agents; then
  echo "変更なし"
else
  git commit -q -m "chore: スキルを同期 ($(hostname -s))" -- agents && echo "コミットしました"
fi

# agents/ 以外に未コミットの作業が残っている場合、pull --rebase の巻き添えを避けて手を引く
if [ -n "$(git status --porcelain | grep -v '^.. agents/' || true)" ]; then
  echo "skip: agents/ 以外に未コミットの変更があるため pull/push は見送り"
  exit 0
fi

# 通信は背景で。失敗してもセッションには影響させず、ログにだけ残す
{
  if git pull --rebase -q origin master && git push -q origin master; then
    echo "$(date '+%F %T') pull/push 完了"
  else
    echo "$(date '+%F %T') pull/push 失敗。手動で確認してください"
  fi
} >>"$LOG" 2>&1 &

exit 0
