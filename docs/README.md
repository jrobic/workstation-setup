# docs/ — workstation runbooks

Operational documentation for the repo. Design/decisions live in the Obsidian vault (**Workstation** domain); here is the practical side.

| Doc | Topic |
| --- | ----- |
| [populate.md](populate.md) | Progressively migrate dotfiles into chezmoi (allowlist, `chezmoi add`, secrets). Answers "will my unmigrated configs be deleted?" |
| [signing.md](signing.md) | Per-machine GPG signing keys + git config + GitHub/GitLab upload. |
| [TODO.md](TODO.md) | Remaining post-migration phases (push, populate chezmoi, cleanup, VM test). |
