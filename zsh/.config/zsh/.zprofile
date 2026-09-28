# ログインシェルの PATH 設定。ZDOTDIR を設定している間、$HOME/.zprofile は読まれないため
# ここが唯一の置き場になる（Homebrew の shellenv がないと brew 自体が PATH から消える）。
# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(pyenv init --path)"

# Setting PATH for Python 3.13
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:${PATH}"
export PATH
