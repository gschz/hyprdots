#!/bin/bash
# Purple Dark — post-install hook for HyDE

THEME_DIR="$(dirname "$(realpath "$0")")"

# Apply KDE color scheme
cp "$THEME_DIR/PurpleDark.colors" ~/.local/share/color-schemes/
kwriteconfig6 --file kdeglobals --group General --key ColorScheme PurpleDark 2>/dev/null || \
kwriteconfig5 --file kdeglobals --group General --key ColorScheme PurpleDark 2>/dev/null

# Apply GTK theme (copy + system config)
if [ -d "$THEME_DIR/gtk/PurpleDark" ]; then
    cp -r "$THEME_DIR/gtk/PurpleDark" ~/.local/share/themes/
fi
gsettings set org.gnome.desktop.interface gtk-theme PurpleDark
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
sed -i 's/gtk-theme-name=.*/gtk-theme-name=PurpleDark/' ~/.config/gtk-3.0/settings.ini
sed -i 's/gtk-theme-name=".*"/gtk-theme-name="PurpleDark"/' ~/.gtkrc-2.0
printf '[Settings]\ngtk-theme-name=PurpleDark\ngtk-application-prefer-dark-theme=1\n' > ~/.config/gtk-4.0/settings.ini

# Apply Kvantum theme
# NOTE: wallbash templates carry the destination path as line 1; strip it
tail -n +2 "$THEME_DIR/kvantum/kvantum.theme" > ~/.config/Kvantum/wallbash/wallbash.svg
tail -n +2 "$THEME_DIR/kvantum/kvconfig.theme" > ~/.config/Kvantum/wallbash/wallbash.kvconfig

# Apply qt6ct palette (Qt apps under QT_QPA_PLATFORMTHEME=qt6ct read the palette
# from here, NOT from kdeglobals; wallbash regenerates a wallpaper-tinted
# wallbash.conf on every wallpaper change, so re-point and re-copy each apply)
mkdir -p ~/.config/qt6ct/colors
cp "$THEME_DIR/qt6ct/PurpleDark.conf" ~/.config/qt6ct/colors/
sed -i "s|^color_scheme_path=.*|color_scheme_path=$HOME/.config/qt6ct/colors/PurpleDark.conf|" ~/.config/qt6ct/qt6ct.conf

# GTK4 hangs with glib2 2.90.x: a settings.ini inside the theme's gtk-4.0 dir
# re-enters the theme settings chain while -gtk-icontheme() resolves during CSS
# parse (subdivide_infos recursion, gtkcssselector.c). Themes must not ship
# that file; HyDE may recreate it, so remove it defensively after install.
rm -f ~/.local/share/themes/PurpleDark/gtk-4.0/settings.ini
rm -f ~/.local/share/themes/PurpleDark/gtk-3.0/settings.ini

# Restart dolphin to pick up new colors
qdbus org.kde.dolphin / Dolphin/MainApplication close 2>/dev/null

echo "Purple Dark theme applied. Restart apps to see changes."
