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
  --help | -h)
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

  # neovim + what NvChad needs (git for lazy.nvim, ripgrep for Telescope,
  # gcc/make/tree-sitter-cli for Treesitter parsers, unzip for Mason)
  local pkgs=(hyprland kitty rofi waybar wlogout pavucontrol pamixer neovim git ripgrep gcc make tree-sitter-cli unzip)

  if command -v pacman >/dev/null 2>&1; then
    local pkg
    for pkg in "${pkgs[@]}"; do
      if [ -n "$runner" ]; then
        if ! $runner pacman -S --needed --noconfirm "$pkg"; then
          echo "Warning: could not install $pkg with pacman; continuing." >&2
        fi
      else
        if ! pacman -S --needed --noconfirm "$pkg"; then
          echo "Warning: could not install $pkg with pacman; continuing." >&2
        fi
      fi
    done
  elif command -v apt-get >/dev/null 2>&1; then
    if [ -n "$runner" ]; then
      $runner apt-get update
    else
      apt-get update
    fi

    local pkg
    for pkg in "${pkgs[@]}"; do
      if [ -n "$runner" ]; then
        if ! $runner apt-get install -y "$pkg"; then
          echo "Warning: could not install $pkg with apt-get; continuing." >&2
        fi
      else
        if ! apt-get install -y "$pkg"; then
          echo "Warning: could not install $pkg with apt-get; continuing." >&2
        fi
      fi
    done
  elif command -v dnf >/dev/null 2>&1; then
    local pkg
    for pkg in "${pkgs[@]}"; do
      if [ -n "$runner" ]; then
        if ! $runner dnf install -y "$pkg"; then
          echo "Warning: could not install $pkg with dnf; continuing." >&2
        fi
      else
        if ! dnf install -y "$pkg"; then
          echo "Warning: could not install $pkg with dnf; continuing." >&2
        fi
      fi
    done
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

# Repo directory -> name in ~/.config
CONFIGS=(
  "hypr:hypr"
  "waybar:waybar"
  "rofi:rofi"
  "kitty:kitty"
  "wlogout:wlogout"
  "neovim/nvim:nvim"
)

# An existing Neovim config (e.g. LazyVim) leaves plugins, Mason packages and
# state behind that clash with NvChad: back them up with the config.
backup_nvim_data() {
  local dst="$CONFIG_DIR/nvim"
  local dir

  # Already pointing into this repo (even an older layout): nothing to migrate
  if [ -L "$dst" ]; then
    case "$(readlink -f -- "$dst")" in
    "$ROOT"/*) return ;;
    esac
  fi
  [ -e "$dst" ] || [ -L "$dst" ] || return 0

  for dir in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    if [ -e "$dir" ]; then
      echo "Backing up existing $dir"
      backup_path "$dir"
    fi
  done
}

link_repo_configs() {
  local entry src dst
  for entry in "${CONFIGS[@]}"; do
    src="$ROOT/${entry%%:*}"
    dst="$CONFIG_DIR/${entry##*:}"

    [ -d "$src" ] || continue

    if [ "${entry##*:}" = "nvim" ]; then
      backup_nvim_data
    fi

    link_dir "$src" "$dst"
  done
}

if [ "$INSTALL_PACKAGES" = true ]; then
  install_required_packages
fi

link_repo_configs

echo "Dotfiles linked from $ROOT"
