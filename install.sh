#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
INSTALL_PACKAGES=true

for arg in "$@"; do
    case "$arg" in
        --no-packages)
            INSTALL_PACKAGES=false
            ;;
        --help|-h)
            cat <<'EOF'
Usage: ./install.sh [--no-packages]

Options:
  --no-packages   Skip package installation and only create symlinks
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

# Create a timestamped backup of an existing path
backup_path() {
    local path="$1"
    local stamp
    stamp="$(date +%s)"
    mv -- "$path" "${path}.backup.${stamp}"
}

ensure_privilege_cmd() {
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        echo ""
    elif command -v sudo >/dev/null 2>&1; then
        echo "sudo"
    else
        echo "Error: root or sudo is required to install packages." >&2
        exit 1
    fi
}

install_required_packages() {
    local runner
    runner="$(ensure_privilege_cmd)"

    if command -v pacman >/dev/null 2>&1; then
        # Core apps requested for the setup.
        local pkgs=(kitty rofi waybar wlogout pavucontrol pamixer)
        if [ -n "$runner" ]; then
            $runner pacman -S --needed --noconfirm "${pkgs[@]}"
        else
            pacman -S --needed --noconfirm "${pkgs[@]}"
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        local pkgs=(kitty rofi waybar wlogout pavucontrol pamixer)
        if [ -n "$runner" ]; then
            $runner apt-get update
            $runner apt-get install -y "${pkgs[@]}"
        else
            apt-get update
            apt-get install -y "${pkgs[@]}"
        fi
    elif command -v dnf >/dev/null 2>&1; then
        local pkgs=(kitty rofi waybar wlogout pavucontrol pamixer)
        if [ -n "$runner" ]; then
            $runner dnf install -y "${pkgs[@]}"
        else
            dnf install -y "${pkgs[@]}"
        fi
    else
        echo "Warning: unsupported package manager. Skipping package installation."
    fi
}

link_dir() {
    local src="$1"
    local dst="$2"

    # If destination is a symlink
    if [ -L "$dst" ]; then
        # If it already points to the same source, skip
        if [ "$(readlink -f -- "$dst")" = "$(readlink -f -- "$src")" ]; then
            echo "Skipping $(basename "$src"): correct symlink exists at $dst"
            return
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
}

if [ "$INSTALL_PACKAGES" = true ]; then
    install_required_packages
fi

targets=(hypr kitty rofi wlogout waybar)

for name in "${targets[@]}"; do
    src="$ROOT/$name"
    dst="$CONFIG_DIR/$name"

    if [ -d "$src" ]; then
        link_dir "$src" "$dst"
    else
        echo "Warning: source folder not found, skipping: $src"
    fi
done

echo "Dotfiles linked from $ROOT"
