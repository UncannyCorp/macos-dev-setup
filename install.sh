#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# macOS Dev Setup (Tabby, NVM, Node v24, pnpm, Colima, etc. via Homebrew)
#
# Requirement: Homebrew must be installed first.
# Usage: curl -fsSL https://raw.githubusercontent.com/UncannyCorp/macos-dev-setup/main/install.sh | bash
#
# Notes:
# - Assumes zsh (default on macOS). Modifies ~/.zshenv, ~/.zprofile, ~/.zshrc.
###############################################################################

echo "==> Starting macOS dev environment setup..."

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it first, then run this script again:" >&2
  echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" >&2
  exit 1
fi

# Detect architecture for Homebrew path
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

ZSHENV="$HOME/.zshenv"
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

# Skip cask install if already installed (via brew or present in /Applications)
install_cask_if_missing() {
  local cask="$1"
  local app_name="$2"
  if brew list --cask "$cask" &>/dev/null || [[ -d "/Applications/$app_name" ]]; then
    echo "    $cask already installed, skipping."
    return 0
  fi
  brew install --cask "$cask"
}

echo "==> 0) Xcode Command Line Tools (if needed)..."
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  echo "    - If a popup appeared, complete the installation, then re-run this script."
fi

echo "==> 1) Ensuring Homebrew is on PATH..."
BREW_SHELLENV_LINE="eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\""
ensure_line_in_file "$BREW_SHELLENV_LINE" "$ZPROFILE"
eval "$(${BREW_PREFIX}/bin/brew shellenv)"

echo "==> 2) Updating Homebrew..."
brew update

echo "==> 3) Installing core CLI tools..."
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

echo "==> 3b) Configuring PATH and env for keg-only tools (curl, unzip)..."
ensure_line_in_file "export PATH=\"${BREW_PREFIX}/opt/curl/bin:\$PATH\"" "$ZSHRC"
ensure_line_in_file "export PATH=\"${BREW_PREFIX}/opt/unzip/bin:\$PATH\"" "$ZSHRC"
ensure_line_in_file "export LDFLAGS=\"-L${BREW_PREFIX}/opt/curl/lib\"" "$ZSHRC"
ensure_line_in_file "export CPPFLAGS=\"-I${BREW_PREFIX}/opt/curl/include\"" "$ZSHRC"
# Apply in current shell so later steps see curl/unzip
export PATH="${BREW_PREFIX}/opt/curl/bin:${BREW_PREFIX}/opt/unzip/bin:$PATH"
export LDFLAGS="-L${BREW_PREFIX}/opt/curl/lib"
export CPPFLAGS="-I${BREW_PREFIX}/opt/curl/include"

echo "==> 4) Installing GUI apps (casks)..."
install_cask_if_missing github "GitHub Desktop.app"
install_cask_if_missing tabby "Tabby.app"

echo "==> 5) Installing Colima + Docker CLI (no Docker Desktop)..."
brew install colima docker docker-compose
# Start Colima if not running
if ! colima status >/dev/null 2>&1; then
  colima start
fi

echo "==> 6) Installing NVM (Node Version Manager)..."
brew install nvm

echo "==> 7) Configuring NVM in zsh (.zshenv, .zprofile, .zshrc so it works in every terminal)..."
mkdir -p "$HOME/.nvm"

# Exact block recommended by Homebrew nvm formula (single [ ] for portability, with comments)
NVM_BLOCK_LINES=(
  'export NVM_DIR="$HOME/.nvm"'
  "[ -s \"${BREW_PREFIX}/opt/nvm/nvm.sh\" ] && \. \"${BREW_PREFIX}/opt/nvm/nvm.sh\"  # This loads nvm"
  "[ -s \"${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm\" ] && \. \"${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm\"  # This loads nvm bash_completion"
)
for rc in "$ZSHENV" "$ZPROFILE" "$ZSHRC"; do
  for line in "${NVM_BLOCK_LINES[@]}"; do
    ensure_line_in_file "$line" "$rc"
  done
done

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

echo "==> 8) Installing Node.js v24 and setting it as default..."
nvm install 24
nvm use 24
nvm alias default 24

echo "==> 9) Installing pnpm..."
corepack enable
corepack prepare pnpm@latest --activate

echo "==> 10) Quick verification..."
echo "---- Versions ----"
git --version || true
brew --version || true
colima version || true
docker version || true
node -v || true
npm -v || true
pnpm -v || true

echo ""
echo "✅ Done. NVM is configured in ~/.zshenv, ~/.zprofile, and ~/.zshrc."
echo "Next steps:"
echo " - Open a NEW terminal tab/window (or run: source ~/.zshenv) so nvm is available."
echo " - If Xcode Command Line Tools were still installing, rerun this script afterward."