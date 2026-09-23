#!/usr/bin/env bash
set -euo pipefail

DEFAULT_BACKUP_DIR="$HOME/backup"

usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [backup_dir]

Commands:
  backup    Create a backup of dotfiles, configs, and workspace
  restore   Restore files onto a fresh machine

Arguments:
  backup_dir  Optional custom backup destination/source path (default: ~/backup)

Options:
  -h, --help  Show this help message
EOF
    exit 1
}

do_backup() {
    local target_dir="$1"
    echo "==> Starting backup to: $target_dir"
    rm -rf "$target_dir"
    mkdir -p "$target_dir"

    echo "-> Backing up SSH and Git..."
    [ -d ~/.ssh ] && cp -r ~/.ssh "$target_dir/ssh"
    [ -f ~/.gitconfig ] && cp ~/.gitconfig "$target_dir/gitconfig"

    echo "-> Backing up GPG (excluding active sockets)..."
    if [ -d ~/.gnupg ]; then
        rsync -av --exclude='S.*' ~/.gnupg/ "$target_dir/gnupg"
    fi

    echo "-> Backing up Shell configs & history..."
    [ -f ~/.vimrc ] && cp ~/.vimrc "$target_dir/vimrc"
    [ -f ~/.zshrc ] && cp ~/.zshrc "$target_dir/zshrc"
    [ -f ~/.p10k.zsh ] && cp ~/.p10k.zsh "$target_dir/p10k.zsh"
    [ -f ~/.zsh_history ] && cp ~/.zsh_history "$target_dir/zsh_history"

    echo "-> Backing up CLI configs & Maven settings..."
    [ -d ~/.config ] && cp -r ~/.config "$target_dir/config"
    if [ -d ~/.m2 ]; then
        rsync -av --exclude='repository' ~/.m2/ "$target_dir/m2"
    fi

    echo "-> Backing up Logseq app settings & notes..."
    [ -d ~/.logseq ] && cp -r ~/.logseq "$target_dir/logseq_app_settings"
    if [ -d ~/Documents/Logseq ]; then
        mkdir -p "$target_dir/logseq_notes"
        cp -r ~/Documents/Logseq/. "$target_dir/logseq_notes/"
    fi

    echo "-> Backing up Workspace..."
    [ -d ~/workspace ] && cp -r ~/workspace "$target_dir/workspace"

    echo "==> Backup completed successfully to $target_dir!"
}

do_restore() {
    local source_dir="$1"
    if [ ! -d "$source_dir" ]; then
        echo "Error: Backup directory '$source_dir' does not exist." >&2
        exit 1
    fi

    echo "==> Starting restore from: $source_dir"

    echo "-> Restoring SSH configuration..."
    if [ -d "$source_dir/ssh" ]; then
        cp -r "$source_dir/ssh" ~/.ssh
        chmod 700 ~/.ssh
        chmod 600 ~/.ssh/* 2>/dev/null || true
    fi

    echo "-> Restoring Git config..."
    [ -f "$source_dir/gitconfig" ] && cp "$source_dir/gitconfig" ~/.gitconfig

    echo "-> Restoring GPG keys & config..."
    if [ -d "$source_dir/gnupg" ]; then
        cp -r "$source_dir/gnupg" ~/.gnupg
        chmod 700 ~/.gnupg
    fi

    echo "-> Restoring Shell configs & history..."
    [ -f "$source_dir/vimrc" ] && cp "$source_dir/vimrc" ~/.vimrc
    [ -f "$source_dir/zshrc" ] && cp "$source_dir/zshrc" ~/.zshrc
    [ -f "$source_dir/p10k.zsh" ] && cp "$source_dir/p10k.zsh" ~/.p10k.zsh
    [ -f "$source_dir/zsh_history" ] && cp "$source_dir/zsh_history" ~/.zsh_history

    echo "-> Restoring CLI configs & Maven settings..."
    [ -d "$source_dir/config" ] && cp -r "$source_dir/config" ~/.config
    [ -d "$source_dir/m2" ] && cp -r "$source_dir/m2" ~/.m2

    echo "-> Restoring Logseq app settings & notes..."
    [ -d "$source_dir/logseq_app_settings" ] && cp -r "$source_dir/logseq_app_settings" ~/.logseq
    if [ -d "$source_dir/logseq_notes" ]; then
        mkdir -p ~/Documents/Logseq
        cp -r "$source_dir/logseq_notes/." ~/Documents/Logseq/
    fi

    echo "-> Restoring Workspace..."
    [ -d "$source_dir/workspace" ] && cp -r "$source_dir/workspace" ~/workspace

    echo "==> Restore completed successfully!"
}

COMMAND="${1:-}"
BACKUP_PATH="${2:-$DEFAULT_BACKUP_DIR}"

case "$COMMAND" in
    backup)
        do_backup "$BACKUP_PATH"
        ;;
    restore)
        do_restore "$BACKUP_PATH"
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        echo "Error: Command 'backup' or 'restore' required." >&2
        usage
        ;;
esac

