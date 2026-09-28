# zsh の設定を XDG Base Directory に寄せる。
# ZDOTDIR 未設定のときだけ zsh はこのファイルを読む。設定済みの環境（入れ子シェル）では
# $ZDOTDIR/.zshenv が読まれるため、実体はそちらに置き、ここからも明示的に読み込む。
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
[ -f "$ZDOTDIR/.zshenv" ] && . "$ZDOTDIR/.zshenv"
