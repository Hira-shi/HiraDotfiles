#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Create a timestamped backup of an existing path
backup_path() {
    local path="$1"
    local stamp
    stamp="$(date +%s)"
    mv -- "$path" "${path}.backup.${stamp}"
}

for src in "$ROOT"/*; do
    name="$(basename "$src")"

    case "$name" in
        hypr|install.sh)
            continue
            ;;
    esac

    if [ -d "$src" ]; then
        dst="$CONFIG_DIR/$name"

        # If destination is a symlink
        if [ -L "$dst" ]; then
            # If it already points to the same source, skip
            if [ "$(readlink -f -- "$dst")" = "$(readlink -f -- "$src")" ]; then
                echo "Skipping $name: correct symlink exists at $dst"
                continue
            else
                echo "Removing differing symlink at $dst"
                rm -- "$dst"
            fi
        elif [ -e "$dst" ]; then
            # If a file/dir exists, back it up
            echo "Backing up existing $dst to ${dst}.backup"
            backup_path "$dst"
        fi

        mkdir -p "$(dirname -- "$dst")"
        ln -s -- "$src" "$dst"
        echo "Linked $dst -> $src"
    fi
done

echo "Dotfiles linked from $ROOT"
