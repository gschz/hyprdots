#!/usr/bin/env bash
# reapply-patches.sh — Re-aplica parches HyDE después de actualizaciones
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="$REPO_DIR/patches"

if [[ ! -d "$PATCH_DIR" ]]; then
    echo "Error: directorio patches/ no encontrado en $REPO_DIR"
    exit 1
fi

PATCHED_LIB="$REPO_DIR/local-lib/hyde"
APPLIED=0
FAILED=0
FAILED_LIST=()

echo "=== reapply-patches ==="
echo "Re-copiando archivos parcheados desde $PATCHED_LIB/"

# Re-copiar archivos parcheados directamente (no usamos patch format ya que
# los archivos completos están en local-lib/hyde/)
declare -A PATCH_MAP=(
    ["color.set.sh"]="$HOME/.local/lib/hyde/color.set.sh"
    ["reload.py"]="$HOME/.local/lib/hyde/reload.py"
    ["lua_env.py"]="$HOME/.local/lib/hyde/pyutils/lua_env.py"
)

for src_name in "${!PATCH_MAP[@]}"; do
    target="${PATCH_MAP[$src_name]}"
    src="$PATCHED_LIB/$src_name"
    [[ "$src_name" == "lua_env.py" ]] && src="$PATCHED_LIB/pyutils/lua_env.py"

    if [[ ! -f "$src" ]]; then
        echo "  Saltando $src_name: no encontrado en local-lib/hyde/"
        continue
    fi

    if [[ ! -f "$target" ]]; then
        echo "  Saltando $src_name: destino $target no existe"
        continue
    fi

    # Verificar si hay diferencias
    if diff -q "$src" "$target" >/dev/null 2>&1; then
        echo "  $src_name: ya está parcheado (sin diferencias)"
        ((APPLIED++))
        continue
    fi

    # Backup
    cp "$target" "${target}.bak.$(date +%Y%m%d%S)"
    # Copiar versión parcheada
    mkdir -p "$(dirname "$target")"
    cp "$src" "$target"
    echo "  $src_name: parche aplicado → $target"
    ((APPLIED++))
done

echo ""
echo "=== Resumen ==="
echo "  Aplicados: $APPLIED"
echo "  Fallidos:  $FAILED"
