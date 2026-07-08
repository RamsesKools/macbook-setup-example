export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git dotenv)

source "$ZSH/oh-my-zsh.sh"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Pyenv
eval "$(pyenv init - zsh)"

# Direnv
eval "$(direnv hook zsh)"

# Poetry
poetry config virtualenvs.in-project true

# Bun
export BUN_INSTALL="$HOME/.bun"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Docker host (Rancher Desktop)
export DOCKER_HOST="unix://$HOME/.rd/docker.sock"

# dbt Fusion alias
alias dbtf="$HOME/.local/bin/dbt"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by dbt installer
export PATH="$PATH:$HOME/.local/bin"

# dbt aliases
alias dbtf="$HOME/.local/bin/dbt"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
