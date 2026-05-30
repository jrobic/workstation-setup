# workstation setup

Unified configuration for my machines: packages, dotfiles, macOS settings, runtimes — orchestrated idempotently and cross-OS.

**Public**: this repo contains no secrets (passwords/tokens injected from Dashlane at apply time). Claude config lives in a separate **private** repo (`claude-config`).

## Stack

| Layer | Tool | Role |
| ------ | ----- | ---- |
| Orchestration / bootstrap | **Ansible** | xcode, brew, mise, SSH keys, macOS defaults, dock |
| macOS packages | **Brewfile** | CLI, GUI casks, fonts, MAS |
| node/go/python/bun runtimes | **mise** | per-project versions (`.mise.toml`/`.nvmrc`) |
| rust runtime | **rustup** | per-project toolchains (`rust-toolchain.toml`) |
| Public dotfiles | **chezmoi** | `~/.zshrc`, `~/.config/*`, per-host templates |
| Claude config (private) | **manual git** | `claude-config` repo cloned to `~/.claude` |
| Secrets | **Dashlane** (`dcli`) | injected at chezmoi apply time |

## Getting started (fresh Mac)

```bash
curl -fsSL https://raw.githubusercontent.com/jrobic/workstation-setup/main/bootstrap.sh | bash
```

The script: Xcode CLT → Homebrew → ansible+git → clone this repo → `ansible-playbook`.

## Common usage

```bash
just sync      # apply state (ansible + chezmoi apply)
just update    # update packages, runtimes, dotfiles, Claude config
just diff      # preview chezmoi changes
just brew      # brew bundle
```

## Structure

```
ansible/        orchestration (inventory, site.yml, roles)
brew/           Brewfile (+ per-host overlay)
home/           chezmoi source (public dotfiles) — see .chezmoiroot
docs/           runbooks (populate.md, signing.md)
bootstrap.sh    fresh machine bootstrap
Justfile        shortcuts (bootstrap/sync/update)
```

## Runbooks (`docs/`)

- [docs/populate.md](docs/populate.md) — migrate dotfiles into chezmoi progressively (nothing is deleted).
- [docs/signing.md](docs/signing.md) — per-machine GPG signing keys + GitHub/GitLab upload.

## Prerequisites (first machine)

- **Dashlane** account + `dcli` (Dashlane CLI, installed via the `dashlane/tap` Homebrew tap).
- Workstation secrets in Dashlane use the **`ws_`** prefix (e.g. `ws_gitlab-pat`).
- **GitLab PAT** in Dashlane under the name `ws_gitlab-pat` (scopes `api` + `write_repository`).
- GitHub auth is via OAuth device flow (`gh auth login`), no PAT needed.

## Secret scanning

This repo is public, so secrets are kept out by three layers:

- **Pre-commit** — `lefthook` runs `gitleaks` on staged changes (blocks the commit).
- **CI** — a GitHub Action scans every push/PR server-side (can't be skipped with `--no-verify`).
- **On demand** — `just scan` audits git history + working tree.

## Hosts

| Host | Status |
| ---- | ------ |
| `mbp` (MacBook Pro) | active |
| `mini` (Mac mini) | planned |
| `pc-rtx` (Linux, RTX 5090) | **stub** (future) |
| `nas-vm` (dev VM) | **stub** (future) |

## Docs

Design and decisions: Obsidian vault → **Workstation** domain (`Workstation — Architecture repos`, `Migration Nix — Cible & Plan`).
