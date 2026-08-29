#!/usr/bin/env bash
# install.sh — Instala hyprdots usando GNU Stow
# Requiere: HyDE instalado, GNU Stow, git-lfs
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LITE_MODE=false
BACKUP_DIR="$HOME/.config/hyprdots-backup/$(date +%Y%m%d-%H%M%S)"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--lite]

Options:
  --lite    Omitir wallpapers (no instalar hyde/themes/*/wallpapers/)

Requisitos:
  - HyDE instalado y funcional
  - GNU Stow
  - git-lfs
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --lite) LITE_MODE=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Opción desconocida: $1"; usage; exit 1 ;;
    esac
done

# Verificar dependencias
for cmd in git stow; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd no encontrado. Instálalo primero."; exit 1; }
done

if ! git -C "$REPO_DIR" lfs >/dev/null 2>&1; then
    echo "Error: git-lfs no disponible."
    exit 1
fi

echo "=== hyprdots install ==="
echo "Repo: $REPO_DIR"
echo "Modo: $([ "$LITE_MODE" = true ] && echo 'lite (sin wallpapers)' || echo 'completo')"
echo ""

# Backup de archivos existentes
backup_if_needed() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        local rel="${target#$HOME/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        cp -a "$target" "$BACKUP_DIR/$rel"
        echo "  Backup: $target → $BACKUP_DIR/$rel"
    fi
}

echo "Preparando backups..."
for dir in hypr waybar kitty rofi; do
    backup_if_needed "$HOME/.config/$dir"
done
backup_if_needed "$HOME/.local/lib/hyde"
backup_if_needed "$HOME/.local/state/hyde"

# VS Code settings (no se symlinkea: VSC gestiona ese directorio)
if [[ -f "$REPO_DIR/code/settings.json" ]]; then
    VSC_DIR="$HOME/.config/Code/User"
    mkdir -p "$VSC_DIR"
    backup_if_needed "$VSC_DIR/settings.json"
    cp -a "$REPO_DIR/code/settings.json" "$VSC_DIR/settings.json"
    echo "  Copiado: $VSC_DIR/settings.json"
fi

echo ""
echo "Creando symlinks con Stow..."

# hypr → ~/.config/hypr
stow -v -d "$REPO_DIR" -t "$HOME/.config" hypr 2>&1

# waybar → ~/.config/waybar
stow -v -d "$REPO_DIR" -t "$HOME/.config" waybar 2>&1

# kitty → ~/.config/kitty
stow -v -d "$REPO_DIR" -t "$HOME/.config" kitty 2>&1

# rofi → ~/.config/rofi
stow -v -d "$REPO_DIR" -t "$HOME/.config" rofi 2>&1

# share → ~/.local/share
stow -v -d "$REPO_DIR" -t "$HOME/.local/share" share 2>&1

# local-lib → ~/.local/lib
stow -v -d "$REPO_DIR" -t "$HOME/.local/lib" local-lib 2>&1

# hyde staterc → ~/.local/state/hyde/
# stow no maneja bien un solo archivo con destino anidado, así que lo copiamos
HYDE_STATE="$HOME/.local/state/hyde"
mkdir -p "$HYDE_STATE"
backup_if_needed "$HYDE_STATE/staterc"
cp -a "$REPO_DIR/hyde/staterc" "$HYDE_STATE/staterc"
echo "  Copiado: $HYDE_STATE/staterc"

# hyde theme → ~/.config/hyde/themes/Purple Dark/
HYDE_THEME_DIR="$HOME/.config/hyde/themes/Purple Dark"
mkdir -p "$HYDE_THEME_DIR"

# Copiar archivos .theme (no wallpapers)
for f in "$REPO_DIR/hyde/themes/Purple Dark/"*.theme; do
    [[ -f "$f" ]] && cp -a "$f" "$HYDE_THEME_DIR/"
done
echo "  Copiado: theme files → $HYDE_THEME_DIR/"

# Copiar archivos extra del tema (install.sh, KDE colors, kvantum, wall.*, .sort)
for extra in install.sh PurpleDark.colors .sort; do
    src="$REPO_DIR/hyde/themes/Purple Dark/$extra"
    [[ -f "$src" ]] && cp -a "$src" "$HYDE_THEME_DIR/"
done
if [[ -d "$REPO_DIR/hyde/themes/Purple Dark/kvantum" ]]; then
    mkdir -p "$HYDE_THEME_DIR/kvantum"
    cp -a "$REPO_DIR/hyde/themes/Purple Dark/kvantum/." "$HYDE_THEME_DIR/kvantum/"
fi
for f in "$REPO_DIR/hyde/themes/Purple Dark/wall.awww.png" "$REPO_DIR/hyde/themes/Purple Dark/wall.hyprlock.png"; do
    [[ -f "$f" ]] && cp -a "$f" "$HYDE_THEME_DIR/"
done

# Wallpapers (skip if --lite)
if [[ "$LITE_MODE" == true ]]; then
    echo ""
    echo "Saltando wallpapers (modo --lite)."
    echo "  Para instalar wallpapers, ejecuta sin --lite."
else
    WP_DIR="$HYDE_THEME_DIR/wallpapers"
    mkdir -p "$WP_DIR"
    # git-lfs pull para obtener wallpapers reales
    if [[ -d "$REPO_DIR/.git" ]]; then
        git -C "$REPO_DIR" lfs pull >/dev/null 2>&1 || true
    fi
    cp -a "$REPO_DIR/hyde/themes/Purple Dark/wallpapers/"* "$WP_DIR/"
    echo "  Copiado: wallpapers → $WP_DIR/"
fi

echo ""
echo "Aplicando parches..."
# Los archivos parcheados están en local-lib/hyde/ y se instalan por Stow.
# No se usan archivos .patch; los scripts completos en local-lib/ reemplazan a los upstream.
echo "  Parches aplicados via Stow: local-lib/hyde/ → ~/.local/lib/hyde/"

if [[ -f "$REPO_DIR/code/settings.json" ]]; then
    echo "  VSC:      code/settings.json → ~/.config/Code/User/"
fi
echo ""
echo "=== Resumen ==="
echo "  Symlinks: hypr, waybar, kitty, rofi, share, local-lib/hyde → ~/.config/ y ~/.local/"
echo "  Theme:    Purple Dark → ~/.config/hyde/themes/"
echo "  State:    staterc → ~/.local/state/hyde/"

if [[ "$LITE_MODE" == false ]]; then
    echo "  Wallpapers: $(ls "$HYDE_THEME_DIR/wallpapers/"* 2>/dev/null | wc -l) archivos instalados."
fi

if [[ -d "$BACKUP_DIR" ]]; then
    echo ""
    echo "Backups en: $BACKUP_DIR"
fi

echo ""
echo "Hecho. HyDE debe ser reiniciado para aplicar los cambios."
