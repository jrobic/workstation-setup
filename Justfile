# Justfile — workstation
# `just` alone lists recipes. See README.md for details.

set shell := ["bash", "-uc"]

# List recipes
default:
    @just --list

# Full machine bootstrap (first run)
bootstrap:
    ./bootstrap.sh

# Apply desired state (idempotent): Ansible + chezmoi dotfiles
sync:
    ansible-galaxy collection install -r ansible/requirements.yml
    ansible-playbook -i ansible/inventory.yml ansible/site.yml --limit localhost -K
    chezmoi apply

# Update everything: packages, runtimes, public dotfiles, private Claude config
update:
    brew update
    brew bundle --file=brew/Brewfile
    brew upgrade
    mise upgrade
    chezmoi update
    git -C ~/code/claude pull --ff-only

# brew bundle only (installs what's missing)
brew:
    brew bundle --file=brew/Brewfile

# Preview chezmoi changes without applying
diff:
    chezmoi diff

# Apply chezmoi changes without previewing
apply:
    chezmoi apply

# Verify playbook syntax
check:
    ansible-playbook -i ansible/inventory.yml ansible/site.yml --syntax-check

# Scan for secrets — git history + working tree (run before going public)
scan:
    gitleaks git --redact --no-banner .
    gitleaks dir --redact --no-banner .

# Clean up brew packages not declared in Brewfile (DESTRUCTIVE: prompts for confirmation)
cleanup:
    brew bundle cleanup --file=brew/Brewfile
