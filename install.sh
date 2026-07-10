#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

install_dir() {
    local src="$1"
    local dst="$2"

    mkdir -p "$dst"

    if command -v rsync >/dev/null 2>&1; then
        rsync -a --delete "$src"/ "$dst"/
    else
        cp -a "$src"/. "$dst"/
    fi
}

for src in "$ROOT"/*; do
    name="$(basename "$src")"

    case "$name" in
        hypr|install.sh)
            continue
            ;;
    esac

    if [ -d "$src" ]; then
        install_dir "$src" "$CONFIG_DIR/$name"
    fi
done

echo "Dotfiles installed from $ROOT"
