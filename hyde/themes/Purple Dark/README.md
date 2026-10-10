# Purple Dark — quirks del theme

Detalles que costaron horas de diagnóstico. No romperlos.

## Formato de templates wallbash (`kvantum/*.theme`)

La **línea 1 es la ruta de destino** (`$HOME/...`), el contenido empieza en la
línea 2. El `install.sh` los instala con `tail -n +2 destino < archivo`,
**nunca con `cp`** — un `cp` crudo deja la línea de ruta dentro del archivo
destino (error típico: `Start tag expected` en el SVG de Kvantum).

Estos templates son **estáticos** (0 tokens `dcol_`): wallbash los re-renderiza
tal cual en cada cambio de wallpaper, así que los colores PurpleDark
recoloreados sobreviven a cualquier wallpaper sin pasar por `wallpaper-apply`.

## `settings.ini` venenoso en `gtk-4.0/`

Un `settings.ini` dentro de `gtk-4.0/` del theme cuelga GTK4 al 100% de CPU
(recursión infinita en `subdivide_infos`, `gtkcssselector.c`, con glib2 ≥ 2.90):
GTK re-entra en la cadena de settings del theme mientras resuelve
`-gtk-icontheme()` durante el parse del CSS. El `install.sh` lo elimina
defensivamente tras copiar el theme (`rm -f`).

## Dolphin: cadena de color real

Dolphin (Qt, sin plasma-integration) NO lee `kdeglobals` — su paleta viene de:

1. **qt6ct**: `color_scheme_path` en `~/.config/qt6ct/qt6ct.conf` → este theme
   instala `qt6ct/PurpleDark.conf` y lo apunta en cada apply (wallbash
   regenera el `wallbash.conf` del wallpaper en cada `-G`, pero queda huérfano).
2. **Kvantum**: las superficies de las vistas las pinta el SVG
   (`~/.config/Kvantum/wallbash/wallbash.svg`), no la paleta ni `base.color`.

El `kvantum.theme` de la fuente ya está recoloreado a PurpleDark
(`#121212`/`#0D0D0D`/`#1A1A1A`/`#A855F7`/`#E0E0E0`); si HyDE lo regenera con
otra paleta, recolorear de nuevo con el mismo mapeo.

## Verificación

Muestreo de píxeles esperado: filas `#121212`, selección `#a855f7`,
toolbar `#121212`/`#0d0d0d`.
