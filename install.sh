#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Fresh macOS Dev Setup (Homebrew + Tabby + NVM + Node v24 + pnpm + Colima etc.)
#
# Usage:
#   1) Save as: setup-dev-macos.sh
#   2) Run:    chmod +x setup-dev-macos.sh && ./setup-dev-macos.sh
#
# Notes:
# - This script assumes zsh (default on macOS).
# - It will modify ~/.zprofile (PATH) and ~/.zshrc (nvm init).
###############################################################################

echo "==> Starting macOS dev environment setup..."

# Detect architecture for Homebrew path
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

ZPROFILE="$HOME/.zprofile"
ZSHRC="$HOME/.zshrc"

ensure_line_in_file() {
  local line="$1"
  local file="$2"
  touch "$file"
  if ! grep -Fqs "$line" "$file"; then
    echo "$line" >> "$file"
  fi
}

echo "==> 1) Installing Xcode Command Line Tools (if needed)..."
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  echo "    - If a popup appeared, complete the installation, then re-run this script."
  # Don't hard fail here because the installer is interactive and may already be in progress.
fi

echo "==> 2) Installing Homebrew (if needed)..."
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> 3) Ensuring Homebrew is on PATH..."
BREW_SHELLENV_LINE="eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\""
ensure_line_in_file "$BREW_SHELLENV_LINE" "$ZPROFILE"
# Load for current session
eval "$(${BREW_PREFIX}/bin/brew shellenv)"

echo "==> 4) Updating Homebrew..."
brew update

echo "==> 5) Installing core CLI tools..."
brew install \
  git \
  wget \
  curl \
  jq \
  yq \
  tree \
  ripgrep \
  fd \
  fzf \
  htop \
  btop \
  tmux \
  watch \
  unzip \
  p7zip \
  gnupg \
  openssl@3

echo "==> 6) Installing GUI apps (casks)..."
brew install --cask \
  github \
  tabby

echo "==> 7) Installing Colima + Docker CLI (no Docker Desktop)..."
brew install colima docker docker-compose
# Start Colima if not running
if ! colima status >/dev/null 2>&1; then
  colima start
fi

echo "==> 8) Installing NVM (Node Version Manager)..."
brew install nvm

echo "==> 9) Configuring NVM in zsh..."
mkdir -p "$HOME/.nvm"

ensure_line_in_file 'export NVM_DIR="$HOME/.nvm"' "$ZSHRC"
ensure_line_in_file '[[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && . "/opt/homebrew/opt/nvm/nvm.sh"' "$ZSHRC"
ensure_line_in_file '[[ -s "/usr/local/opt/nvm/nvm.sh" ]] && . "/usr/local/opt/nvm/nvm.sh"' "$ZSHRC"
ensure_line_in_file '[[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"' "$ZSHRC"
ensure_line_in_file '[[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ]] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"' "$ZSHRC"

# Load nvm into current shell session
export NVM_DIR="$HOME/.nvm"
if [[ -s "${BREW_PREFIX}/opt/nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  . "${BREW_PREFIX}/opt/nvm/nvm.sh"
fi
if [[ -s "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ]]; then
  # shellcheck disable=SC1090
  . "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"
fi

echo "==> 10) Installing Node.js v24 and setting it as default..."
nvm install 24
nvm use 24
nvm alias default 24

echo "==> 11) Installing pnpm..."
# Recommended: enable Corepack (ships with Node) and use it to install pnpm cleanly
corepack enable
corepack prepare pnpm@latest --activate

echo "==> 12) Quick verification..."
echo "---- Versions ----"
git --version || true
brew --version || true
colima version || true
docker version || true
node -v || true
npm -v || true
pnpm -v || true

echo ""
echo "✅ Done."
echo "Next steps:"
echo " - Open Tabby from Applications."
echo " - Restart your terminal (or run: source ~/.zshrc) so nvm is always available."
echo " - If Xcode Command Line Tools were still installing, rerun this script afterward."