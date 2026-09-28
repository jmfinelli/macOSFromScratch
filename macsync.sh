#!/usr/bin/env bash
set -euo pipefail

DEFAULT_BACKUP_DIR="$HOME/backup"

check_zen_env() {
    if [ -n "${ZEN_PATH:-}" ]; then
        RESOLVED_ZEN_PATH="$ZEN_PATH"
    elif [ -n "${ZEN_HOME:-}" ]; then
        RESOLVED_ZEN_PATH="$ZEN_HOME"
    elif [ -n "${ZEN_PROFILE_DIR:-}" ]; then
        RESOLVED_ZEN_PATH="$ZEN_PROFILE_DIR"
    else
        local candidate
        for candidate in \
            "$HOME/Library/Application Support/Zen" \
            "$HOME/Library/Application Support/zen" \
            "$HOME/Library/Application Support/ZenBrowser" \
            "$HOME/Library/Application Support/Zen Browser"; do
            if [ -d "$candidate" ]; then
                RESOLVED_ZEN_PATH="$candidate"
                return 0
            fi
        done

        echo "Error: Zen directory not found and no environment variable is defined." >&2
        echo "" >&2
        echo "Checked candidate paths:" >&2
        echo "  - ~/Library/Application Support/Zen" >&2
        echo "  - ~/Library/Application Support/zen" >&2
        echo "  - ~/Library/Application Support/ZenBrowser" >&2
        echo "  - ~/Library/Application Support/Zen Browser" >&2
        echo "" >&2
        echo "To find your actual path, open Zen, navigate to about:support, and check 'Profile Directory'." >&2
        echo "Then set ZEN_PATH in your environment or ~/.zshrc:" >&2
        echo '  export ZEN_PATH="/path/to/your/Zen"' >&2
        exit 1
    fi

    if [ ! -d "$RESOLVED_ZEN_PATH" ]; then
        echo "Error: Directory '$RESOLVED_ZEN_PATH' specified in environment variable does not exist." >&2
        exit 1
    fi
}

usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [backup_dir]

Commands:
  backup    Create a backup of dotfiles, configs, workspace, and Zen session file
  restore   Restore files onto a fresh machine and copy Zen session file

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
        rsync -av \
            --exclude='repository' \
            --exclude='wrapper' \
            --exclude='.*/' \
            ~/.m2/ "$target_dir/m2"
    fi

    echo "-> Backing up Logseq app settings & notes..."
    [ -d ~/.logseq ] && cp -r ~/.logseq "$target_dir/logseq_app_settings"
    if [ -d ~/Documents/Logseq ]; then
        mkdir -p "$target_dir/logseq_notes"
        cp -r ~/Documents/Logseq/. "$target_dir/logseq_notes/"
    fi

    echo "-> Backing up Workspace..."
    [ -d ~/workspace ] && cp -r ~/workspace "$target_dir/workspace"

    echo "-> Backing up latest Zen Browser session file..."
    latest_session=$(find "$RESOLVED_ZEN_PATH" -type f -name "zen-sessions-*.jsonlz4" -exec ls -td {} + 2>/dev/null | head -n 1 || true)
    if [ -n "$latest_session" ] && [ -f "$latest_session" ]; then
        cp "$latest_session" "$target_dir/zen-sessions.jsonlz4"
        echo "   Saved: $(basename "$latest_session") -> $target_dir/zen-sessions.jsonlz4"
    else
        echo "   No zen-sessions-*.jsonlz4 snapshot found in $RESOLVED_ZEN_PATH."
    fi

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

    echo "-> Restoring Zen Browser session..."
    if [ -f "$source_dir/zen-sessions.jsonlz4" ]; then
        if [ -d "$RESOLVED_ZEN_PATH/Profiles" ]; then
            find "$RESOLVED_ZEN_PATH/Profiles" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | while IFS= read -r pdir; do
                cp "$source_dir/zen-sessions.jsonlz4" "$pdir/zen-sessions.jsonlz4"
                echo "   Copied zen-sessions.jsonlz4 to $pdir/"
            done
        else
            mkdir -p "$RESOLVED_ZEN_PATH"
            cp "$source_dir/zen-sessions.jsonlz4" "$RESOLVED_ZEN_PATH/zen-sessions.jsonlz4"
            echo "   Copied to $RESOLVED_ZEN_PATH/zen-sessions.jsonlz4"
        fi
    fi

    echo "==> Restore completed successfully!"
}

COMMAND="${1:-}"
BACKUP_PATH="${2:-$DEFAULT_BACKUP_DIR}"

case "$COMMAND" in
    backup)
        check_zen_env
        do_backup "$BACKUP_PATH"
        ;;
    restore)
        check_zen_env
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
