# すべての zsh（入れ子・非対話を含む）で読まれる。
# PATH の重複を排除する。brew shellenv や pyenv init は実行のたび無条件に前置するため、
# -U を付けないと入れ子のログインシェルで PATH が際限なく伸びる。
typeset -U path PATH fpath FPATH
