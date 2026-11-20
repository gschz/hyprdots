#!/usr/bin/env bash
# sddm/sync-to-repo.sh — Copia el tema SDDM instalado (live) al repo
# Solo lectura del sistema; no requiere sudo. Se ejecuta manualmente.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_SRC="/usr/share/sddm/themes/violet-noir-sddm"
THEME_DST="$REPO_DIR/sddm/themes/violet-noir-sddm"

[[ -d "$THEME_SRC" ]] || { echo "Error: el tema no está instalado en $THEME_SRC"; exit 1; }

rm -rf "$THEME_DST"
mkdir -p "$(dirname "$THEME_DST")"
cp -r "$THEME_SRC" "$THEME_DST"
echo "  Copiado: $THEME_DST"
echo ""
