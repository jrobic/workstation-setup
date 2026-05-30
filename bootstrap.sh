#!/usr/bin/env bash
# Bootstrap a fresh machine — macOS.
# Usage (fresh Mac):
#   curl -fsSL https://raw.githubusercontent.com/jrobic/workstation-setup/main/bootstrap.sh | bash
#
# Idempotent: safe to re-run.
set -euo pipefail

REPO_URL="${WORKSTATION_REPO:-https://github.com/jrobic/workstation-setup.git}"
REPO_DIR="${WORKSTATION_DIR:-$HOME/code/workstation-setup}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
err() { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || err "bootstrap.sh targets macOS. For Linux, see the README."

# 1. Xcode Command Line Tools (Apple GUI prompt)
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (Apple window)…"
  xcode-select --install || true
  log "Waiting for Xcode installation to complete…"
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew…"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Load brew in current shell (Apple Silicon)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Minimal tools to run Ansible
log "Installing ansible + git…"
brew install ansible git

# 4. Clone (or update) repo
if [ ! -d "$REPO_DIR/.git" ]; then
  log "Cloning workstation → $REPO_DIR…"
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR"
else
  log "Repo already present, pulling…"
  git -C "$REPO_DIR" pull --ff-only || true
fi
cd "$REPO_DIR"

# 5. Required Ansible collections
log "Installing Ansible collections…"
ansible-galaxy collection install -r ansible/requirements.yml

# 6. Playbook (local machine). -K prompts for sudo password.
log "Running Ansible playbook (localhost)…"
ansible-playbook -i ansible/inventory.yml ansible/site.yml --limit localhost -K

log "Bootstrap complete. Open a new shell to load the environment."
