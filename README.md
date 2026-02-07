# 🍎 macOS Dev Setup

Dev environment setup on macOS: CLI tools, Tabby, Docker (Colima), Node.js 24, pnpm. Uses Homebrew.

---

## Requirements

**Homebrew** (install first if needed):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## Installation

Replace `UncannyCorp` with your GitHub username or org:

```bash
curl -fsSL https://raw.githubusercontent.com/UncannyCorp/macos-dev-setup/main/install.sh | bash
```

---

## What gets installed

| Category | Packages / tools |
|----------|-------------------|
| **🛠️ CLI** | git, wget, curl, jq, yq, tree, ripgrep, fd, fzf, htop, btop, tmux, watch, unzip, p7zip, gnupg, openssl@3 |
| **🖥️ GUI (casks)** | GitHub Desktop, Tabby terminal |
| **🐳 Containers** | Colima, Docker CLI, docker-compose (no Docker Desktop) |
| **📗 Node** | NVM, Node.js v24, pnpm (via Corepack) |

The script may trigger Xcode Command Line Tools; complete that, then re-run if needed.

---

## After install

- Restart your terminal (or run `source ~/.zshrc`) so NVM is available.
- Open **Tabby** from Applications if you want to use it.

---

## Documentation

[GitHub Pages](https://UncannyCorp.github.io/macos-dev-setup/) (replace `UncannyCorp` with the repo owner).
