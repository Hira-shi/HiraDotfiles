#!/bin/bash

THEME=$1
VALID_THEMES=("catppuccin" "gruvbox" "tokyonight")

if [ -z "$THEME" ]; then
    echo "Usage: ./switch-theme.sh [catppuccin|gruvbox|tokyonight]"
    echo "Thèmes disponibles:"
    for t in "${VALID_THEMES[@]}"; do
        echo "  - $t"
    done
    exit 1
fi

if [[ ! " ${VALID_THEMES[@]} " =~ " ${THEME} " ]]; then
    echo "Erreur: Thème '$THEME' inconnu"
    echo "Thèmes disponibles: ${VALID_THEMES[*]}"
    exit 1
fi

if [ ! -d ~/.config/hypr/themes/$THEME ]; then
    echo "Erreur: Dossier ~/.config/hypr/themes/$THEME introuvable"
    exit 1
fi

# Change le symlink hyprpaper
ln -sf ~/.config/hypr/themes/$THEME/hyprpaper.conf ~/.config/hypr/hyprpaper.conf

# Change le fichier lookandfeel
cp ~/.config/hypr/themes/$THEME/lookandfeel.lua ~/.config/hypr/hyprconf/lookandfeel.lua

# Change le fichier hyprlock
cp ~/.config/hypr/themes/$THEME/hyprlock.conf ~/.config/hypr/hyprlock.conf

# Change le fichier kitty
cp ~/.config/hypr/themes/$THEME/kitty.conf ~/.config/kitty/kitty.conf

# Recharge la configuration kitty pour toutes les instances ouvertes
kill -USR1 $(pgrep kitty) 2>/dev/null || true

# Change le thème nvim selon le thème
case "$THEME" in
    "catppuccin")
        sed -i 's/colorscheme = ".*"/colorscheme = "catppuccin-mocha"/' ~/.config/nvim/lua/plugins/colorscheme.lua
        ;;
    "gruvbox")
        sed -i 's/colorscheme = ".*"/colorscheme = "gruvbox"/' ~/.config/nvim/lua/plugins/colorscheme.lua
        ;;
    "tokyonight")
        sed -i 's/colorscheme = ".*"/colorscheme = "tokyonight"/' ~/.config/nvim/lua/plugins/colorscheme.lua
        ;;
esac

# Redémarre hyprpaper
killall hyprpaper 2>/dev/null
sleep 0.5
hyprpaper &

# Recharger la configuration Hyprland
hyprctl reload

echo "✓ Thème changé vers: $THEME"