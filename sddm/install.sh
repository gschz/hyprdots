#!/usr/bin/env bash
# sddm/install.sh — Instala el tema SDDM Violet Noir en /usr/share/sddm/themes
# Ruta del sistema: requiere sudo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SRC="$SCRIPT_DIR/themes/violet-noir-sddm"
THEME_DST="/usr/share/sddm/themes/violet-noir-sddm"
ACTIVATE=false

[[ -d "$THEME_SRC" ]] || { echo "Error: no se encontró $THEME_SRC"; exit 1; }

for arg in "$@"; do
    case "$arg" in
        --activate) ACTIVATE=true ;;
        -h|--help) echo "Usage: $(basename "$0") [--activate]"; exit 0 ;;
        *) echo "Opción desconocida: $arg"; exit 1 ;;
    esac
done

sudo rm -rf "$THEME_DST"
sudo cp -r "$THEME_SRC" "$THEME_DST"
echo "  Copiado (sudo): $THEME_DST"

if [[ "$ACTIVATE" == true ]]; then
    sudo sed -i 's/^Current=.*/Current=violet-noir-sddm/' /etc/sddm.conf
    echo "  Activado: Current=violet-noir-sddm en /etc/sddm.conf"
else
    echo "  Activar:  sudo sed -i 's/^Current=.*/Current=violet-noir-sddm/' /etc/sddm.conf"
fi
echo "  Preview:  sddm-greeter-qt6 --test-mode --theme $THEME_DST"
