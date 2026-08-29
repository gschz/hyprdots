#!/bin/bash
# Purple Dark — post-install hook for HyDE

THEME_DIR="$(dirname "$(realpath "$0")")"

# Apply KDE color scheme
cp "$THEME_DIR/PurpleDark.colors" ~/.local/share/color-schemes/
kwriteconfig6 --file kdeglobals --group General --key ColorScheme PurpleDark 2>/dev/null || \
kwriteconfig5 --file kdeglobals --group General --key ColorScheme PurpleDark 2>/dev/null

# Apply Kvantum theme
cp "$THEME_DIR/kvantum/kvantum.theme" ~/.config/Kvantum/wallbash/wallbash.svg
cp "$THEME_DIR/kvantum/kvconfig.theme" ~/.config/Kvantum/wallbash/wallbash.kvconfig

# Restart dolphin to pick up new colors
qdbus org.kde.dolphin / Dolphin/MainApplication close 2>/dev/null

echo "Purple Dark theme applied. Restart apps to see changes."
