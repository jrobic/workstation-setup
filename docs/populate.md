# Populating dotfiles in chezmoi (progressively)

The chezmoi source (`home/`) initially contains only the core: `dot_zshrc`, `dot_aliases.tmpl`, `dot_config/mise`, `dot_config/ohmyposh`. The rest of `~/.config/*` migrates **at your own pace**, file by file.

## Nothing is deleted — you can migrate progressively ✅

This is the key guarantee:

- **`chezmoi apply` only manages files present in the source.** Unmigrated dotfiles (`~/.config/gh`, `~/.config/zed`, etc.) are **left untouched** — chezmoi doesn't see them, doesn't touch them, doesn't delete them.
- **Exception to know**: a directory prefixed with `exact_` in the source will delete everything on the target side that isn't declared. This repo uses `dot_config/` (not `exact_dot_config/`) → **no deletion**. Don't add `exact_` unintentionally.
- **`brew bundle` doesn't remove anything either**: it installs what's missing, but doesn't uninstall packages outside the Brewfile. Only `just cleanup` (= `brew bundle cleanup`, explicit and destructive) prunes.

⚠️ **Caveat**: files **already migrated** (`~/.zshrc`, `~/.aliases`) are **overwritten** by the managed version on the next `chezmoi apply` — that's the goal. Verify they are correct before the first apply (`chezmoi diff`).

## Triage `~/.config/`

| Folder | Action | Reason |
| ------- | ------ | ------ |
| btop, htop, neofetch, qmd | `chezmoi add` | pure config |
| ohmyposh, mise | already in source | — |
| zed | inspect then `chezmoi add` | may contain AI assistant API key |
| git (`~/.gitconfig`) | `chezmoi add --template` + Dashlane | per-machine signingkey (see signing.md) |
| gh, glab-cli, github-copilot, configstore | **never** | tokens → regenerated at bootstrap |
| filezilla | **never** | FTP passwords in plaintext |
| iterm2, raycast, jgit, nix | **never** | state/license/binary, or deprecated |

## `chezmoi add` workflow

> The agent's secret-guard blocks Claude on `.gitconfig`/`.ssh`/`credentials`.
> Run these `chezmoi add` commands **yourself** (terminal, or with `!` prefix in the session).

```bash
# 1. Safe configs (add directly to source)
chezmoi add ~/.config/btop ~/.config/htop ~/.config/neofetch ~/.config/qmd

# 2. File with per-machine/known value → auto-template
chezmoi add --autotemplate ~/.config/zed/settings.json

# 3. File carrying a secret → template then Dashlane injection
chezmoi add --template ~/.gitconfig
#   edit source: replace secret with {{ dashlanePassword "item" }}

# 4. Non-templatable secret → encrypt in source (age/gpg)
chezmoi add --encrypt <file>
```

Standard cycle afterward:

```bash
chezmoi add ~/.config/xxx     # populate source
chezmoi re-add                # re-sync managed files after $HOME edits
chezmoi diff                  # preview before apply
chezmoi apply                 # materialize
git -C ~/code/workstation-setup add home/ && git commit   # version
```

## Golden rule

Before any `chezmoi add` of an unknown file: **verify it contains no token/key/password** (`grep -iE 'token|key|secret|password'`). The `workstation` repo is **public**.
