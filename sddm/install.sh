#!/usr/bin/env bash
# Install SDDM + Sugar Candy theme with the GRUB prana classroom background
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
THEME_DIR=/usr/share/sddm/themes/sugar-candy
BACKGROUND=/boot/grub/themes/prana/background-classroom.png

sudo pacman -S --needed sddm qt5-declarative qt5-graphicaleffects qt5-quickcontrols2 qt5-svg

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
git clone --depth 1 https://framagit.org/MarianArlt/sddm-sugar-candy.git "$tmp/sugar-candy"
rm -rf -- "$tmp/sugar-candy/.git"

sudo rm -rf -- "$THEME_DIR"
sudo cp -r -- "$tmp/sugar-candy" "$THEME_DIR"
sudo install -Dm644 -- "$BACKGROUND" "$THEME_DIR/Backgrounds/prana-classroom.png"
sudo install -Dm644 -- "$ROOT/theme.conf.user" "$THEME_DIR/theme.conf.user"
sudo install -Dm644 -- "$ROOT/sddm.conf" /etc/sddm.conf.d/theme.conf

# Replace the current display manager (gdm) with sddm on next boot
sudo systemctl enable -f sddm.service

echo "Done. Preview: sddm-greeter --test-mode --theme $THEME_DIR"
