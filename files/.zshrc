export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="cobalt2"

plugins=(git)

source $ZSH/oh-my-zsh.sh

. /opt/homebrew/opt/asdf/libexec/asdf.sh

# gcloud project swhich
function gcloud_prj_switch () {
  project="$(gcloud projects list | peco)"
  project_name="$(echo $project | awk '{print $1}')"
  project_id="$(echo $project | awk '{print $3}')"
  gcloud config set project ${project_id}
  export GOOGLE_PROJECT=${project_id}
  echo "Switched to project: ${project_name}(${project_id})"
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ryuya/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryuya/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ryuya/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryuya/google-cloud-sdk/completion.zsh.inc'; fi

# historyの重複を無視
setopt hist_ignore_dups

# ビープ音の停止
setopt no_beep

# ビープ音の停止(補完時)
setopt nolistbeep

# 同時に起動した zsh の間でヒストリを共有する
setopt share_history

# 直前と同じコマンドの場合はヒストリに追加しない
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# fc コマンドでカレントディレクトリ以下のディレクトリを絞り込んだ後に移動する
function find_cd() {
  cd "$(find . -type d | peco)"
}
alias fc="find_cd"

# pk で実行中のプロセスを選択して kill
function peco-pkill() {
  for pid in `ps aux | peco | awk '{ print $2 }'`
  do
    kill $pid
    echo "Killed ${pid}"
  done
}
alias pk="peco-pkill"
