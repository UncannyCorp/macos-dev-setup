# 🍎 macOS Dev Setup

Quick, one-command dev environment setup on macOS: Homebrew, CLI tools, Tabby, Docker (Colima), Node.js 24, and pnpm.

---

## ⚡ One-command install

Paste this into your terminal (replace `UncannyCorp` with your GitHub username or org):

```bash
curl -fsSL https://raw.githubusercontent.com/UncannyCorp/macos-dev-setup/main/install.sh | bash
```

**Prerequisites:** macOS, zsh (default on macOS). The script may trigger an Xcode Command Line Tools install; complete that, then re-run the script if needed.

---

## 📦 What gets installed

| Category | Packages / tools |
|----------|-------------------|
| **🛠️ CLI** | Xcode Command Line Tools, Homebrew, git, wget, curl, jq, yq, tree, ripgrep, fd, fzf, htop, btop, tmux, watch, unzip, p7zip, gnupg, openssl@3 |
| **🖥️ GUI (casks)** | GitHub Desktop, Tabby terminal |
| **🐳 Containers** | Colima, Docker CLI, docker-compose (no Docker Desktop) |
| **📗 Node** | NVM, Node.js v24, pnpm (via Corepack) |

---

## ✅ After install

- Restart your terminal (or run `source ~/.zshrc`) so NVM is available.
- Open **Tabby** from Applications if you want to use it.
- If Xcode Command Line Tools were still installing when you ran the script, run the one-liner again afterward.

---

## 📄 Documentation

Full install page: [GitHub Pages](https://UncannyCorp.github.io/macos-dev-setup/) (replace `UncannyCorp` with the repo owner).
