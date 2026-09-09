#!/usr/bin/env bash
# sync-to-repo.sh — Copia configuraciones live al repo
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verificar que estamos en el repo
if [[ ! -d "$REPO_DIR/.git" ]]; then
    echo "Error: no se detectó un repositorio git en $REPO_DIR"
    exit 1
fi

COPIED=0
UNCHANGED=0
SKIPPED=0

echo "=== sync-to-repo ==="
echo "Sincronizando configs live → $REPO_DIR"

sync_file() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "$src" ]]; then
        echo "  Saltando $src: no existe"
        ((SKIPPED++))
        return
    fi

    mkdir -p "$(dirname "$dst")"

    if [[ -f "$dst" ]] && diff -q "$src" "$dst" >/dev/null 2>&1; then
        ((UNCHANGED++))
        return
    fi

    cp "$src" "$dst"
    echo "  Copiado: $dst"
    ((COPIED++))
}

# Hyprland
sync_file "$HOME/.config/hypr/hyprland.lua" "$REPO_DIR/hypr/hyprland.lua"
for f in env.lua hyprglass.lua input.lua keybinds.lua layer_rules.lua monitors.lua window_rules.lua workspaces.lua; do
    sync_file "$HOME/.config/hypr/lua/$f" "$REPO_DIR/hypr/lua/$f"
done
sync_file "$HOME/.config/hypr/animations.conf" "$REPO_DIR/hypr/animations.conf"
sync_file "$HOME/.config/hypr/hypridle.conf" "$REPO_DIR/hypr/hypridle.conf"
# hyprlock.conf se omite a propósito: HyDE lo regenera con rutas absolutas
# ($HOME -> /home/gsanz) que romperían la portabilidad del repo.
sync_file "$HOME/.config/hypr/hyprsunset.conf" "$REPO_DIR/hypr/hyprsunset.conf"

# Waybar
sync_file "$HOME/.config/waybar/config.jsonc" "$REPO_DIR/waybar/config.jsonc"
sync_file "$HOME/.config/waybar/user-style.css" "$REPO_DIR/waybar/user-style.css"
sync_file "$HOME/.config/waybar/includes/border-radius.css" "$REPO_DIR/waybar/includes/border-radius.css"
sync_file "$HOME/.config/waybar/includes/global.css" "$REPO_DIR/waybar/includes/global.css"
sync_file "$HOME/.config/waybar/modules/cliphist.jsonc" "$REPO_DIR/waybar/modules/cliphist.jsonc"

# Kitty
sync_file "$HOME/.config/kitty/kitty.conf" "$REPO_DIR/kitty/kitty.conf"

# Rofi
sync_file "$HOME/.config/rofi/config.rasi" "$REPO_DIR/rofi/config.rasi"
sync_file "$HOME/.config/rofi/theme.rasi" "$REPO_DIR/rofi/theme.rasi"

# Local share (waybar layouts/styles)
sync_file "$HOME/.local/share/waybar/layouts/hyprdots/gsanz.jsonc" "$REPO_DIR/share/waybar/layouts/hyprdots/gsanz.jsonc"
sync_file "$HOME/.local/share/waybar/styles/hyprdots.css" "$REPO_DIR/share/waybar/styles/hyprdots.css"

# HyDE theme (Purple Dark)
sync_file "$HOME/.config/hyde/themes/Purple Dark/hypr.theme" "$REPO_DIR/hyde/themes/Purple Dark/hypr.theme"
sync_file "$HOME/.config/hyde/themes/Purple Dark/kitty.theme" "$REPO_DIR/hyde/themes/Purple Dark/kitty.theme"
sync_file "$HOME/.config/hyde/themes/Purple Dark/rofi.theme" "$REPO_DIR/hyde/themes/Purple Dark/rofi.theme"
sync_file "$HOME/.config/hyde/themes/Purple Dark/waybar.theme" "$REPO_DIR/hyde/themes/Purple Dark/waybar.theme"
sync_file "$HOME/.config/hyde/themes/Purple Dark/install.sh" "$REPO_DIR/hyde/themes/Purple Dark/install.sh"
sync_file "$HOME/.config/hyde/themes/Purple Dark/PurpleDark.colors" "$REPO_DIR/hyde/themes/Purple Dark/PurpleDark.colors"

# State
sync_file "$HOME/.local/state/hyde/staterc" "$REPO_DIR/hyde/staterc"

# Local-lib
sync_file "$HOME/.local/lib/hyde/cliphist.sh" "$REPO_DIR/local-lib/hyde/cliphist.sh"
sync_file "$HOME/.local/lib/hyde/color.set.sh" "$REPO_DIR/local-lib/hyde/color.set.sh"
sync_file "$HOME/.local/lib/hyde/reload.py" "$REPO_DIR/local-lib/hyde/reload.py"
sync_file "$HOME/.local/lib/hyde/pyutils/lua_env.py" "$REPO_DIR/local-lib/hyde/pyutils/lua_env.py"

echo ""
echo "=== Resumen ==="
echo "  Copiados:    $COPIED"
echo "  Sin cambios: $UNCHANGED"
echo "  Saltados:    $SKIPPED"
echo ""
echo "No se ejecuta commit automáticamente. Revisa y ejecuta:"
echo "  cd $REPO_DIR && git add -A && git commit -m 'sync: configs actualizadas'"
