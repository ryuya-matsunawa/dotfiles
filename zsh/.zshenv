# zsh の設定を XDG Base Directory に寄せる。
# ~/.zshenv だけは zsh が $HOME 直下を固定で読むため、ここでしか ZDOTDIR を宣言できない。
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
