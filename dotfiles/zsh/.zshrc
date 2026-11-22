#---
# version: 5.0 - Fedora Surface Edition (adapted from WSL2 v4.3)
# changes: Fedora dnf, linux-surface paths, kitty/ghostty agnostic, pyenv/nvm integrated.
#          WSL2 helpers removed. apt -> dnf. Paths fixed for cheta-surface.
#          Oh-my-zsh with plugins. cutz/macros compatible (function descriptions in format
#          'funcname() { # description' are auto-parsed for help display).
#---
#
# WORKFLOW:
#   Terminal 1: proxy-up       - start the proxy stack, KEEP IT OPEN
#   Terminal 2: cc             - new Claude session through proxy
#               ccc            - resume last Claude session through proxy

# ============================================================
# SHELL INITIALIZATION
# ============================================================

autoload -Uz compinit
ZSH_COMPINIT_CACHE="$HOME/.zcompcache"
if [[ -f "$ZSH_COMPINIT_CACHE" && (! -f "${ZDOTDIR:-$HOME}/.zcompdump" || "${ZDOTDIR:-$HOME}/.zcompdump" -ot "$ZSH_COMPINIT_CACHE") ]]; then
  compinit -i -d "$ZSH_COMPINIT_CACHE"
else
  compinit -i
fi

# Oh-My-Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(
  git
  zsh-autosuggestions
  colored-man-pages
  command-not-found
  history-substring-search
  zsh-syntax-highlighting
)
source "$ZSH/oh-my-zsh.sh"

# ============================================================
# HISTORY
# ============================================================

setopt histignorealldups sharehistory
HISTSIZE=400000
SAVEHIST=400000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS HIST_REDUCE_BLANKS
HIST_STAMPS="mm/dd/yyyy"

clean_old_history() { # Remove history entries older than 180 days
  local temp_histfile cutoff
  temp_histfile=$(mktemp)
  if date -d "180 days ago" >/dev/null 2>&1; then
    cutoff=$(date -d "180 days ago" '+%s')
  else
    cutoff=$(date -v-180d '+%s' 2>/dev/null || echo 0)
  fi
  fc -R "$HISTFILE"
  awk -v cutoff="$cutoff" 'BEGIN { FS=":"; OFS=":" } /^:/ && NF >= 2 { if ($2 ~ /^[0-9]+$/ && $2 < cutoff) next } { print }' "$HISTFILE" > "$temp_histfile"
  mv "$temp_histfile" "$HISTFILE"
  chmod 600 "$HISTFILE"
}

local last_clean_file="$HOME/.zsh_history_last_clean"
if [[ ! -f "$last_clean_file" || $(command find "$last_clean_file" -mtime +7 2>/dev/null) ]]; then
  clean_old_history
  touch "$last_clean_file"
fi

# ============================================================
# SECRETS
# ============================================================

SECRETS_FILE="$HOME/.secrets"
[[ -f "$SECRETS_FILE" ]] && source "$SECRETS_FILE"

# ============================================================
# EXPORTS & ENVIRONMENT
# ============================================================

# Shell & terminal
export SHELL_PROMPT_MANAGER="starship"
export DEFAULT_USER="${ZSH_DEFAULT_USER:-cheta-surface}"
export TERM=xterm-256color

# Development
export EDITOR="nano"
export VISUAL="$EDITOR"

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Syntax highlighting styles
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=242'
ZSH_HIGHLIGHT_STYLES[cursor]='bg=33'
ZSH_HIGHLIGHT_STYLES[selection]='bg=33,fg=white'
ZSH_HIGHLIGHT_STYLES[matched-bracket]='fg=magenta,bold'

# ============================================================
# PATH
# ============================================================

typeset -U path
path=(
  "$HOME/.hermes/bin"                    # Hermes agent CLI
  "$HOME/.opencode/bin"                  # AI CLI tools
  "$HOME/.brv-cli/bin"                   # ByteRover CLI
  "$HOME/.npm-global/bin"                # npm global packages
  "$HOME/.cargo/bin"                     # Rust toolchain (eza, bat, fd, zoxide)
  "$HOME/.local/share/pnpm"              # pnpm package manager
  "$HOME/.local/bin"                     # Local user binaries
  "$HOME/bin"
  "$HOME/code/scripts"                   # Custom scripts
  "/home/linuxbrew/.linuxbrew/bin"       # Homebrew
  "/home/linuxbrew/.linuxbrew/sbin"
  "/usr/local/bin"                       # Local builds before system
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/sbin"
  $path                                  # Preserve existing PATH entries
)
export PATH

# Python (pyenv via install script)
if [[ -d "$HOME/.pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)" 2>/dev/null || true
  eval "$(pyenv virtualenv-init -)" 2>/dev/null || true
fi

# Node (nvm -- shell function, loaded lazily)
export NVM_DIR="$HOME/.nvm"
if [[ -f "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
  [[ -f "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true

# ============================================================
# COMPLETION SYSTEM
# ============================================================

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
fi
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ============================================================
# KEY BINDINGS
# ============================================================

bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Bracketed paste is ON (default) -- pasted text lands in buffer without auto-executing.
# Use Alt+Shift+V to flatten pasted newlines to spaces if needed.
flatten-paste() { # Flatten pasted newlines to spaces (Alt+Shift+V)
  local trimmed=$(printf '%s' "$BUFFER" | tr '\n' ' ' | sed 's/[[:space:]]*$//')
  BUFFER="$trimmed"
  CURSOR=$#BUFFER
}
zle -N flatten-paste
bindkey "^[^V" flatten-paste

# FZF keybindings (zsh)
FZF_KEYBINDINGS_PATH="/usr/share/fzf/shell/key-bindings.zsh"
[[ -f "$FZF_KEYBINDINGS_PATH" ]] && source "$FZF_KEYBINDINGS_PATH"

# ============================================================
# PROMPT & THEME
# ============================================================

export STARSHIP_SHELL=zsh
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  print -P "%F{yellow}starship not found; prompt initialization skipped.%f"
fi

# ============================================================
# FUNCTIONS
# ============================================================

# --- System Utilities ---

portsscan() { # Check which processes are using specified ports
  if ! command -v lsof >/dev/null 2>&1; then
    print -P "%F{red}Error: lsof not found. Install with: sudo dnf install lsof%f"
    return 1
  fi
  for port in "$@"; do
    echo "=== Port $port ===";
    lsof -i :$port 2>/dev/null || echo "FREE";
    echo;
  done
}

mkcd() { # Create directory and cd into it
  mkdir -p -- "$1" && cd -- "$1"
}

up() { # Go up N directory levels (default: 1)
  cd $(printf '../'%.0s {1..${1:-1}})
}

t() { # Show colored tree view with exclusions
  if command -v eza >/dev/null 2>&1; then
    eza --tree --all --color=auto -I ".git|node_modules|vendor" -L "${1:-2}" "${2:-.}"
  elif command -v tree >/dev/null 2>&1; then
    tree -aC -I ".git|node_modules|vendor" -L "${1:-2}" "${2:-.}"
  else
    print -P "%F{red}Error: neither 'eza' nor 'tree' found. Install: sudo dnf install eza%f"
    return 1
  fi
}

logview() { # View log files with colored output
  local log_file="$1" filter="${2:-.*}"
  [[ -z "$log_file" ]] && { print -P "%F{red}Usage: logview <logfile> [filter_pattern]%f"; return 1; }
  [[ ! -r "$log_file" ]] && { print -P "%F{red}Error: Cannot read '$log_file'%f"; return 1; }
  local file_size=$(stat -c%s "$log_file" 2>/dev/null || stat -f%z "$log_file" 2>/dev/null || echo 0)
  local awk_script='{printf "\033[38;5;%dm%s\033[0m\n", 232+(NR%23)+1, $0}'
  if (( file_size > 1048576 )); then
    tail -f "$log_file" | command grep --color=never --line-buffered "$filter" | awk "$awk_script"
  else
    <"$log_file" command grep --color=never "$filter" | awk "$awk_script"
  fi
}

proj() { # Select and cd to project directory via fzf
  local projects_roots=($HOME/code)
  local project_dirs=$(command find "${projects_roots[@]}" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
  [[ -z "$project_dirs" ]] && { print -P "%F{yellow}No project directories found.%f"; return 1; }
  local selected=$(echo "$project_dirs" | fzf --prompt="Select Project: " --height=40% --border)
  if [[ -n "$selected" ]]; then
    cd "$selected" || return 1
    if [[ -f package.json ]]; then
      [[ ! -d node_modules ]] && npm install
    elif [[ -f Gemfile ]]; then
      command -v bundle &>/dev/null && bundle install --path vendor/bundle
    fi
  fi
}

auto_env() { # Auto-source .env file when entering directory
  local env_file=".env"
  [[ ! -f "$env_file" || ! -r "$env_file" ]] && return 0
  local file_size=$(stat -c%s "$env_file" 2>/dev/null || stat -f%z "$env_file" 2>/dev/null || echo 0)
  (( file_size > 1048576 )) && { print -P "%F{red}auto_env: .env too large%f"; return 1; }
  source "$env_file" 2>/dev/null && [[ "${AUTO_ENV_VERBOSE:-false}" == "true" ]] && print -P "%F{green}auto_env: Loaded .env from $(pwd)%f"
}

chpwd_functions+=("auto_env")

showbigfiles() { # Find files >1GB in specified path
  local search_path="${1:-.}"
  print -P "%F{yellow}Searching for files >1GB in '$search_path'...%f"
  command find "$search_path" -type f -size +1G -exec ls -lh {} + 2>/dev/null | awk '{printf "\033[31m%s\033[0m %s\n", $5, $9}'
}

showbigdirs() { # Find directories >1GB in specified path
  local search_path="${1:-.}"
  print -P "%F{yellow}Calculating directory sizes >1GB in '$search_path'...%f"
  du -h -L 1 "$search_path" 2>/dev/null | command grep -E '^[0-9.]+G' | awk '{printf "\033[31m%s\033[0m %s\n", $1, $2}'
}

sha() { # SHA-256 hash compare -- confirms files are identical
  [[ $(sha256sum "$@" | tee /dev/tty | cut -d ' ' -f 1 | sort -u | wc -l) -eq 1 ]] && echo "Equivalent" || echo "Not Equivalent"
}

update-system() { # Full system update: dnf + flatpak + brew + cargo + npm global
  print -P "%F{cyan}Updating dnf packages...%f"
  sudo dnf upgrade --refresh -y
  print -P "%F{cyan}Updating flatpak...%f"
  flatpak update -y 2>/dev/null
  if command -v brew >/dev/null 2>&1; then
    print -P "%F{cyan}Updating brew...%f"
    brew update && brew upgrade 2>/dev/null || true
  fi
  if command -v cargo >/dev/null 2>&1; then
    print -P "%F{cyan}Updating cargo-installed tools...%f"
    cargo install-update -a 2>/dev/null || cargo install "$(cargo install --list 2>/dev/null | grep -E '^ ' | awk '{print $1}' | sort -u)" 2>/dev/null || true
  fi
  if command -v npm >/dev/null 2>&1; then
    print -P "%F{cyan}Updating npm global packages...%f"
    npm update -g 2>/dev/null || true
  fi
  print -P "%F{green}System update complete.%f"
}

# --- Git Helpers ---

_commit_and_push() {
  local default_message="$1" user_message="$2" push_flags="$3"
  git add .
  if [ -z "$user_message" ]; then
    git commit -m "$default_message"
  else
    git commit -m "$user_message"
  fi
  if ! git push $push_flags 2>/dev/null; then
    echo "Push failed - attempting to sync with remote..."
    if git pull origin main --allow-unrelated-histories --no-edit 2>/dev/null; then
      echo "Merged with remote - retrying push..."
      git push $push_flags
    else
      echo "Forcing push..."
      git push $push_flags --force
    fi
  fi
}

gacp() { # Git add, commit, push with optional message
  _commit_and_push "Update" "$1" ""
}

ganp() { # Git add, commit, push for new repo
  _commit_and_push "Initial commit" "$1" "-u origin main"
}

ginit() { # Initialize git repo with remote origin
  local repo_name="$1"
  [[ -z "$repo_name" ]] && { echo "Usage: ginit <repo_name> [message]"; return 1; }
  git init
  [[ ! -f ".gitignore" ]] && touch .gitignore
  git remote add origin "https://github.com/${GIT_USER_NAME:-cheta-surface}/${repo_name}.git"
  git config user.name "${GIT_USER_NAME:-cheta-surface}"
  git config user.email "${GIT_USER_EMAIL:-cheta@surface}"
  _commit_and_push "Initial commit" "$2" "-u origin main"
}

ginitplus() { # Initialize repo with README, .gitignore
  local repo_name="$1"
  [[ -z "$repo_name" ]] && { echo "Usage: ginitplus <repo_name> [message]"; return 1; }
  git init
  [[ ! -f "README.md" ]] && echo "# $repo_name" > README.md
  [[ ! -f ".gitignore" ]] && touch .gitignore
  echo "context-portal/" >> .gitignore
  git remote add origin "https://github.com/${GIT_USER_NAME:-cheta-surface}/${repo_name}.git"
  git config user.name "${GIT_USER_NAME:-cheta-surface}"
  git config user.email "${GIT_USER_EMAIL:-cheta@surface}"
  _commit_and_push "Initial commit" "$2" "-u origin main"
}

# --- Helper Functions ---

# Override cd to treat 'cd \' as 'cd ~' (backslash -> home)
cd() {
  if [[ "$1" == "\\" || "$1" == "\\\\" ]]; then
    builtin cd ~
  else
    builtin cd "$@"
  fi
}

# --- Cutz / Macros (self-documenting shell reference) ---

aicli() { # AI CLI & agent launchers reference card
  local C='\033[0m' B='\033[1m' G='\033[1;32m' Y='\033[1;33m' CY='\033[1;36m' D='\033[2m'
  echo ""
  echo -e "${B}${CY}AI CLIs & AGENTS${C}"
  echo -e "${D}--------------------------------------------------------${C}"
  echo -e "  ${B}Claude  ${C} ${G}cc${C} start     ${G}ccc${C} continue    ${D}(cldo OAuth  cc-mini)${C}"
  echo -e "  ${B}Hermes  ${C} ${G}hs${C} start    ${G}hsr${C} resume"
  echo -e "  ${B}OpenCode${C} ${G}oc${C} start     ${G}oc-c${C} continue     ${D}(ocl/ocl-c openclaw)${C}"
  echo ""
  echo -e "  ${B}${Y}PROXY STACK${C}    ${G}proxy-up${C} start  ${G}proxy-stat${C}  ${G}killproxys${C}  ${G}proxy-restart${C}"
  echo ""
}

cutz() { # Display aliases and function names with descriptions
  aicli
  local zshrc="$HOME/.zshrc"
  [[ -r "$zshrc" ]] || { echo "Can't read .zshrc"; return 1; }

  local C_RESET='\033[0m' C_CYAN='\033[1;36m' C_YELLOW='\033[1;33m' C_GREEN='\033[1;32m'
  local C_WHITE='\033[1;37m' C_DIM='\033[2;37m' C_ORANGE='\033[38;5;208m' C_PINK='\033[38;5;213m'

  local cols=${COLUMNS:-120}
  local desc_max=$(( (cols > 80) ? 28 : (cols - 22) ))
  (( desc_max < 10 )) && desc_max=10
  local two_col=$(( cols > 80 ? 1 : 0 ))

  echo ""
  echo -e "${C_CYAN}======================================${C_RESET}"
  echo -e "${C_CYAN}  ZSH SHORTCUTS & FUNCTIONS REFERENCE ${C_RESET}"
  echo -e "${C_CYAN}======================================${C_RESET}"
  echo ""

  _cutz_print() {
    local color="$1"; shift
    local items=("$@")
    local total=${#items[@]}
    if (( two_col )); then
      local half=$(( (total + 1) / 2 )) i=0
      while (( i < half )); do
        local left="${items[$((i+1))]:-}" right="${items[$((i+1+half))]:-}"
        local lname="${left%%|*}" ldesc="${left#*|}" rname="${right%%|*}" rdesc="${right#*|}"
        (( ${#ldesc} > desc_max )) && ldesc="${ldesc:0:$((desc_max-3))}..."
        (( ${#rdesc} > desc_max )) && rdesc="${rdesc:0:$((desc_max-3))}..."
        if [[ -n "$rname" ]]; then
          printf "  ${color}%-14s${C_RESET} ${C_DIM}>${C_RESET} ${C_WHITE}%-${desc_max}s${C_RESET}  ${color}%-14s${C_RESET} ${C_DIM}>${C_RESET} ${C_WHITE}%s${C_RESET}\n" \
            "$lname" "$ldesc" "$rname" "$rdesc"
        else
          printf "  ${color}%-14s${C_RESET} ${C_DIM}>${C_RESET} ${C_WHITE}%s${C_RESET}\n" "$lname" "$ldesc"
        fi
        (( i++ ))
      done
    else
      local item
      for item in "${items[@]}"; do
        local name="${item%%|*}" desc="${item#*|}"
        (( ${#desc} > desc_max )) && desc="${desc:0:$((desc_max-3))}..."
        printf "  ${color}%-14s${C_RESET} ${C_DIM}>${C_RESET} ${C_WHITE}%s${C_RESET}\n" "$name" "$desc"
      done
    fi
  }

  echo -e "${C_GREEN}FUNCTIONS${C_RESET}"
  echo -e "${C_DIM}------------------------------------------------------${C_RESET}"
  local funcs=()
  while IFS= read -r line; do
    funcs+=("$line")
  done < <(command grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{[[:space:]]*#' "$zshrc" | \
    sed -E 's/^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)\\(\\)[[:space:]]*\{[[:space:]]*#[[:space:]]*(.*)/\1|\2/')
  _cutz_print "$C_GREEN" "${funcs[@]}"
  echo ""

  echo -e "${C_ORANGE}ALIASES${C_RESET}"
  echo -e "${C_DIM}------------------------------------------------------${C_RESET}"
  local aliases=()
  while IFS= read -r line; do
    aliases+=("$line")
  done < <(command grep -E "^[[:space:]]*alias[[:space:]]+" "$zshrc" | command grep '#' | \
    sed -E "s/^[[:space:]]*alias[[:space:]]+([^=]+)=.*#[[:space:]]*(.*)/\1|\2/")
  _cutz_print "$C_PINK" "${aliases[@]}"

  echo ""
  echo -e "${C_DIM}------------------------------------------------------${C_RESET}"
  echo -e "${C_CYAN}Tip:${C_RESET} Add ${C_DIM}# comment${C_RESET} after aliases/functions for auto-docs"
  echo -e "${C_CYAN}Run:${C_RESET} ${C_GREEN}cutz${C_RESET}"
  echo ""
}

# --- Proxy Stack Helpers ---

proxy-up() { # Start claude-code-proxy (foreground, keep open)
  cd "$HOME/code/claude-code-proxy" && uv run python start_proxy.py
}

proxy-stat() { # Check proxy health endpoints
  local p8082=$(curl -sf --max-time 1 http://127.0.0.1:8082/health 2>/dev/null && echo "GREEN" || echo "RED")
  local p8787=$(curl -sf --max-time 1 http://127.0.0.1:8787/health 2>/dev/null && echo "GREEN" || echo "RED")
  echo "Proxy   :8082 $p8082"
  echo "Headroom:8787 $p8787"
}

proxy-restart() { # Kill and restart proxy stack
  killproxys 2>/dev/null
  sleep 1
  proxy-up
}

killproxys() { # Kill proxy processes
  kill $(pgrep -f "start_proxy.py") $(pgrep -f "cli-proxy-api") 2>/dev/null
}

# ============================================================
# ALIASES
# ============================================================

# --- MODERN RUST TOOLCHAIN ---
alias ls='eza --icons --group-directories-first -a'   # Modern ls with icons and sorting
alias ll='eza --icons --group-directories-first -la --git --header --time-style=long-iso'   # Long listing with git status
alias la='eza --icons --group-directories-first -la --tree --level=3'   # Tree view depth 3
alias tree='eza --tree'   # Tree view simple
alias cat='bat --style=plain --paging=never'   # cat with syntax highlighting no paging
alias grep='rg'   # Use ripgrep (faster than grep)
alias find='fd'   # Use fd (faster than find)

# --- EDITOR / IDE ---
alias code="flatpak run com.visualstudio.code"   # VS Code (Flatpak)
alias vsc="flatpak run com.visualstudio.code"   # VS Code shorthand

# --- FILE OPERATIONS ---
alias rm='rm -iv'   # Interactive remove (confirms before delete)
alias cp='cp -iv'   # Interactive copy (confirms before overwrite)
alias mv='mv -iv'   # Interactive move (confirms before overwrite)

# --- NAVIGATION ---
alias ..='cd ..'   # Go up one directory
alias ...='cd ../..'   # Go up two directories
alias ....='cd ../../..'   # Go up three directories
alias h='history'   # Show command history
alias hg='history | grep'   # Search command history
alias j='jobs -l'   # List active background jobs
alias cdp='cd $HOME/code'   # Jump to Projects Root
alias c.='code .'   # Open VS Code in current dir
alias open='xdg-open'   # Open file/URL with default app

# --- SYSTEM & MAINTENANCE ---
alias update='update-system'   # Full system update (dnf+flatpak+brew+cargo+npm)
alias checkproxy='env | grep -i proxy'   # Check proxy env vars
alias macros='cutz'   # Show alias help menu
alias zsh='source ~/.zshrc'   # Reload shell config safely
alias zshrc='source ~/.zshrc'   # Reload shell config safely

# --- DEV TOOLS ---
alias lint-py='ruff check .'   # Python lint via Ruff
alias lint-js='eslint .'   # JS lint via ESLint
alias lint-ts='tsc --noEmit'   # TypeScript type check
alias pn='pnpm'   # pnpm shortcut
alias pnx='pnpm dlx'   # pnpm dlx shortcut
alias list-ext='code --list-extensions'   # List VS Code extensions
alias install-ext='code --install-extension'   # Install VS Code extension
alias uninstall-ext='code --uninstall-extension'   # Uninstall VS Code extension

# --- GIT SHORTCUTS ---
alias gco='git checkout'   # Git checkout
alias gst='git status'   # Git status
alias gpl='git pull'   # Git pull
alias gph='git push'   # Git push
alias gaa='git add .'   # Git add all
alias glog='git log --oneline --graph --decorate -20'   # Pretty git log (20 entries)
alias gdiff='git diff --stat'   # Git diff summary
alias gundo='git reset --hard HEAD~1'   # Undo last commit (DANGEROUS)
alias gclean='git branch --merged | grep -v "*\|main\|master" | xargs -n 1 git branch -d'   # Delete merged branches

# --- AI CLI LAUNCHERS ---
# Claude via proxy
alias cc='ANTHROPIC_BASE_URL=http://127.0.0.1:8082 ANTHROPIC_API_KEY=pass claude --dangerously-skip-permissions'   # Claude new session via proxy
alias ccc='ANTHROPIC_BASE_URL=http://127.0.0.1:8082 ANTHROPIC_API_KEY=pass claude --continue --dangerously-skip-permissions'   # Claude resume via proxy
alias cld='claude --dangerously-skip-permissions'   # Claude direct (no proxy)
alias cld-c='claude --continue --dangerously-skip-permissions'   # Claude direct continue

# Hermes
alias hs='hermes'   # Hermes start
alias hsr='hermes --resume'   # Hermes resume

# OpenCode via proxy
alias oc='OPENAI_BASE_URL=http://127.0.0.1:8082/p/opencode/v1 OPENAI_API_KEY=pass opencode'   # OpenCode via proxy
alias ocl='OPENAI_BASE_URL=http://127.0.0.1:8082/p/opencode/v1 OPENAI_API_KEY=pass openclaw'   # OpenClaw via proxy

# OpenClaw completions
[[ -f "/home/cheta-surface/.openclaw/completions/openclaw.zsh" ]] && source "/home/cheta-surface/.openclaw/completions/openclaw.zsh"

# Legacy muscle memory
alias ccproxy='proxy-up'   # Start proxy stack
alias car='cc'   # Legacy alias for cc
alias carc='ccc'   # Legacy alias for ccc
alias cproxy-init='cc'   # Legacy alias for cc
alias cproxy-continue='ccc'   # Legacy alias for ccc

# --- CUSTOM SCRIPTS ---
alias ss="$HOME/code/scripts/ss.sh"   # Ghostty theme switcher
alias gswitch="$HOME/code/scripts/gswitch.sh"   # Ghostty profile switch

# --- ZOMBIE KILLERS ---
alias terminal-orphan='[[ -x "$HOME/code/Wonky/terminal_orphan_killer/terminal_orphan.sh" ]] && $HOME/code/Wonky/terminal_orphan_killer/terminal_orphan.sh || echo "Script not found"'   # Kill orphan terminal processes
alias to='terminal-orphan'   # Shorthand for terminal-orphan

# --- SYSTEM INFO ---
alias meminfo='cat /proc/meminfo | command grep -E "MemTotal|MemFree|MemAvailable"'   # Show memory info
alias pstop='top -b -n 1 | head -20'   # Quick process list
alias please='sudo'   # Sudo polite version

# ============================================================
# OPTIONAL RUNTIME
# ============================================================

# Zoxide (smarter cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Direnv (auto-env via .envrc)
eval "$(direnv hook zsh)" 2>/dev/null || true

# Envman
[[ -s "$HOME/.config/envman/load.sh" ]] && source "$HOME/.config/envman/load.sh"

# ============================================================
# GNOME SESSION VARIABLES (fix for settings)
# ============================================================

export XDG_CURRENT_DESKTOP=GNOME
export DESKTOP_SESSION=gnome
export GDMSESSION=gnome

# ============================================================
# D-Bus / gnome-keyring bootstrap (for OAuth tokens)
# ============================================================

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && [ -S "/run/user/$(id -u)/bus" ]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi
if [ -n "$DBUS_SESSION_BUS_ADDRESS" ] && [ -z "$GNOME_KEYRING_CONTROL" ]; then
  systemctl --user start gnome-keyring-daemon.socket gnome-keyring-daemon.service 2>/dev/null
  export GNOME_KEYRING_CONTROL="/run/user/$(id -u)/keyring"
fi

# ============================================================
# FINAL PATH GUARD
# ============================================================

export PATH="$HOME/.local/bin:$PATH"