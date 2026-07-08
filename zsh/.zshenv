export NVM_DIR="$HOME/.nvm"
export PYENV_ROOT="$HOME/.pyenv"
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew/Homebrew"
export HOMEBREW_NO_INSTALL_CLEANUP=TRUE
# export CPPFLAGS="-I$(brew --prefix openssl)/include"  # needed for some C extension builds

export PATH="$HOME/.nvm/versions/node/v22.11.0/bin:$PATH"
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOME/.rd/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

fpath[1,0]="/opt/homebrew/share/zsh/site-functions"
export FPATH

eval "$(/usr/bin/env PATH_HELPER_ROOT=\"/opt/homebrew\" /usr/libexec/path_helper -s)"
[ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
