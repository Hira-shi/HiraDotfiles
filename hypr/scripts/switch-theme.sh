#!/bin/bash

THEME=$1
VALID_THEMES=("catppuccin" "gruvbox" "kanagawa" "blackmetal")
REPO_ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

if [ -z "$THEME" ]; then
    echo "Usage: ./switch-theme.sh [catppuccin|gruvbox|kanagawa|blackmetal]"
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

# Change la palette Waybar (style.css l'importe) et les couleurs des <span> de config.jsonc
WAYBAR_COLORS="$REPO_ROOT/waybar/themes/$THEME/colors.css"
cp "$WAYBAR_COLORS" ~/.config/waybar/colors.css
ACCENT=$(sed -n 's/^@define-color accent \(#[0-9a-fA-F]\{6\}\);/\1/p' "$WAYBAR_COLORS")
MUTED=$(sed -n 's/^@define-color muted \(#[0-9a-fA-F]\{6\}\);/\1/p' "$WAYBAR_COLORS")
sed -i -E "s/foreground='#[0-9a-fA-F]{6}'/foreground='$ACCENT'/g; s/fgcolor='#[0-9a-fA-F]{6}'/fgcolor='$MUTED'/g" "$REPO_ROOT/waybar/config.jsonc"

# Redémarre Waybar pour appliquer le nouveau thème immédiatement
killall waybar 2>/dev/null || true
sleep 0.5
waybar &

# Recharge la configuration kitty pour toutes les instances ouvertes
kill -USR1 $(pgrep kitty) 2>/dev/null || true

# Change le thème base46 de NvChad selon le thème
case "$THEME" in
    "catppuccin") NVIM_THEME="catppuccin" ;;
    "gruvbox") NVIM_THEME="chocolate" ;;
    "kanagawa") NVIM_THEME="kanagawa-dragon" ;;
    "blackmetal") NVIM_THEME="yoru" ;;
esac
CHADRC="$HOME/.config/nvim/lua/chadrc.lua"
if [ -n "$NVIM_THEME" ] && [ -f "$CHADRC" ]; then
    sed -i "/^M.base46 = {/,/^}/ s/theme = \"[^\"]*\"/theme = \"$NVIM_THEME\"/" "$CHADRC"
    if command -v nvim >/dev/null 2>&1; then
        # base46 lit un cache compilé au démarrage : on le régénère
        nvim --headless -c 'lua require("base46").load_all_highlights()' -c 'qa' >/dev/null 2>&1 || true
        # et on recharge le thème dans les nvim déjà ouverts (un socket par instance)
        for sock in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/nvim.*.0; do
            [ -S "$sock" ] || continue
            timeout 2 nvim --server "$sock" --remote-expr \
                "luaeval('require(\"nvchad.themes.utils\").reload_theme(\"$NVIM_THEME\")')" >/dev/null 2>&1 || true
        done
    fi
fi

# Redémarre hyprpaper
killall hyprpaper 2>/dev/null
sleep 0.5
hyprpaper &

# Recharger la configuration Hyprland
hyprctl reload

echo "✓ Thème changé vers: $THEME"
