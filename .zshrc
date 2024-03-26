eval "$(starship init zsh)"

[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"

ZSH_THEME="cobalt2"

plugins=(git)

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ryuya/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryuya/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ryuya/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryuya/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
eval "$(pyenv init -)"
export PATH=$HOME/.nodebrew/current/bin:$PATH

# history
HISTFILE=$HOME/.zsh-history
HISTSIZE=100000
SAVEHIST=1000000

# share .zshhistory
setopt inc_append_history
setopt share_history

alias tac='tail -r'
alias distinct='awk '\''!a[$0]++'\'

# peco
function peco-select-history() {
    BUFFER=`history -n 1 | tac | distinct | peco`
    CURSOR=${#BUFFER}
    zle reset-prompt
}

zle -N peco-select-history
bindkey '^r' peco-select-history

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

## ghqとの連携。ghqの管理化にあるリポジトリを一覧表示する。ctrl - ]にバインド。
function peco-src () {
  local selected_dir=$(ghq list -p | peco --prompt="repositories >" --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="code ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src
