# TODO — phases restantes

Suivi des étapes post-migration. La migration nix-darwin → Ansible + Brew + Chezmoi est **terminée et validée end-to-end** sur `mbp` (2026-05-30). Doc de conception : coffre Obsidian, domaine *Workstation* (note `Workstation — Architecture repos`).

## À faire

- [ ] **Push** les commits locaux → `git -C ~/code/workstation-setup push`. Met à jour le repo **public** ; gitleaks tourne déjà en hook pre-commit + CI.
- [ ] **Peupler chezmoi** progressivement (voir [populate.md](populate.md)) :
  - `chezmoi add ~/.config/{btop,htop,neofetch,qmd}` (sûrs, pas de secret)
  - `chezmoi add --template ~/.gitconfig` (signingkey via `~/.gitconfig.local`, cf. [signing.md](signing.md))
  - `~/.config/zed` après inspection (peut contenir une clé API d'assistant IA)
  - **Jamais** : `gh`, `glab-cli`, `configstore`, `filezilla` (secrets/tokens)
- [ ] **Nettoyer `~/.bun/install/cache`** (~1,6 Go, reconstructible) : `bun pm cache rm`.
  - ⚠️ **NE PAS** `rm -rf ~/.bun` : `~/.bun/install/global` (~310 Mo) contient les paquets globaux **actifs** (qmd `@tobilu`, marp `@marp-team`, puppeteer, node-llama-cpp, MCP…). `BUN_INSTALL` non défini → bun (même via mise) lit/écrit ses globaux là.
- [ ] **Repo `jr-claude-code-setup`** (`~/code/claude`, symlink `~/.claude`) : ajouter un `.gitignore` (exclure `projects/`, `cache/`, `history.jsonl`, `node_modules/`, `claude.json`, `*.bak`…), `git rm -r --cached` le runtime, puis scanner l'historique avec `gitleaks git ~/code/claude` (secrets possibles : `claude.json` a `oauthAccount`, `history.jsonl` des transcripts).
- [ ] **Tester le playbook sur une VM neuve** (Tart, macOS Apple Silicon) = vrai test fresh-machine bout-en-bout via `bootstrap.sh`. Sur `mbp` c'était idempotent mais machine déjà configurée.

## Prérequis 1ère machine (rappel)

- PAT GitLab dans Dashlane sous `ws_gitlab-pat` (scopes `api` + `write_repository`).
- `gh auth refresh -s write:gpg_key` (pour l'upload de la clé GPG sur GitHub).
- Être connecté à l'App Store (pour le module `mas`).

## Fait (référence)

- ✅ Résidus nix nettoyés : `n` (brew), `~/.n`, `~/.config/nix`, `/usr/local/go`, `starship`.
- ✅ Playbook ansible joué jusqu'à `failed=0` idempotent ; gotchas consignés dans `Workstation — Architecture repos` (wiki).
