# hyprdots

Configuración personal de HyDE/Hyprland para Arch Linux.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/652f4e1c-6e44-44a9-954d-24092ef7da3a" />

## Prerrequisitos

| Requisito  | Versión          | Propósito                         |
| ---------- | ---------------- | --------------------------------- |
| Arch Linux | Actual           | SO objetivo                       |
| HyDE       | Latest (post-RC) | Framework base                    |
| GNU Stow   | 2.x              | Gestión de symlinks               |
| git-lfs    | 3.x              | Almacenamiento de wallpapers      |
| Hyprland   | 0.57.2           | Compositor                        |
| hyprglass  | 1.2.0            | Plugin de cristal (release `.so`) |

### hyprglass

Se instala el binario precompilado del release correspondiente a la línea de
Hyprland en uso (no via `hyprpm`):

```bash
# ~/.local/share/hyprglass/hyprglass.so
# Cargado desde el hook hyprland.start de hypr/lua/hyprglass.lua
```

Si el `.so` está compilado para otra versión de Hyprland, el plugin carga pero
queda pausado y `hyprctl hyprglass` devuelve "unknown request". Verifica con:

```bash
hyprctl hyprglass status   # debe decir: active + version check: match
```

## Instalación

```bash
# Clonar con wallpapers
gh repo clone gschz/hyprdots
cd hyprdots
git lfs pull
./install.sh

# Sin wallpapers (más ligero)
./install.sh --lite
```

### Qué hace `install.sh`

1. Detecta archivos existentes en `~/.config/` y crea backups en `~/.config/hyprdots-backup/{timestamp}/`
2. Usa Stow para crear symlinks de `hypr/`, `waybar/`, `kitty/`, `rofi/`, `local-lib/hyde/` hacia `~/.config/` y `~/.local/`
3. Copia el theme `Purple Dark` y el state file `staterc`
4. Los parches HyDE se aplican via Stow (archivos completos en `local-lib/hyde/`)

## Modo `--lite`

Cuando ejecutas `./install.sh --lite`:

- Se omiten los wallpapers
- Todos los demás componentes se instalan normalmente
- Para wallpapers después, ejecuta sin `--lite` o copia manualmente desde `hyde/themes/Purple Dark/wallpapers/`

## Tema SDDM — Violet Noir (opt-in)

Tema de pantalla de login para SDDM (Qt6), construido sobre
[sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) como
variante **Violet Noir**.

```bash
sddm/install.sh --activate   # instala (sudo) y activa el tema
sddm/sync-to-repo.sh         # cambios del tema instalado → repo
```

![Violet Noir — pantalla de login](./sddm/screenshot.png)

## Parches HyDE

Los archivos en `local-lib/` son versiones parcheadas de scripts upstream de HyDE:

| Archivo        | Modificación                                                    |
| -------------- | --------------------------------------------------------------- |
| `color.set.sh` | Variables dcol_rgb extendidas, sed de reemplazo mejorado        |
| `reload.py`    | Targets `python`, `lua`, `cache`, `theme` + manejo de errores   |
| `lua_env.py`   | Gestor de entorno Lua con luarocks del sistema + `--force-lock` |
| `cliphist.sh`  | Gestor de portapapeles con favoritos sensibles y fixes de rofi  |

Después de cada actualización de HyDE, ejecuta:

```bash
./reapply-patches.sh
```

## Estructura del repositorio

```
hyprdots/
├── .gitattributes          # LFS para wallpapers
├── .gitignore              # Reglas de exclusión
├── README.md
├── install.sh              # Instalación con Stow
├── reapply-patches.sh      # Re-aplicar parches HyDE
├── sync-to-repo.sh         # Sincronizar configs live → repo
├── hypr/                   # Config Hyprland + módulos Lua
│   ├── hyprland.lua
│   ├── animations.conf
│   ├── hypridle.conf
│   ├── hyprlock.conf
│   ├── hyprsunset.conf
│   └── lua/*.lua
├── waybar/                 # Config Waybar
│   ├── config.jsonc
│   ├── user-style.css
│   ├── includes/*.css
│   └── modules/*.jsonc
├── kitty/kitty.conf        # Config Kitty
├── rofi/                   # Config Rofi
├── code/                   # VS Code User settings
│   └── settings.json
├── share/                  # Datos en ~/.local/share
│   └── waybar/
│       ├── layouts/hyprdots/gsanz.jsonc
│       └── styles/hyprdots.css
├── hyde/
│   ├── staterc
│   └── themes/Purple Dark/
│       ├── *.theme
│       └── wallpapers/     # git-lfs (~47MB)
├── local-lib/              # Parches HyDE
│   └── hyde/
│       ├── cliphist.sh
│       ├── color.set.sh
│       ├── reload.py
│       └── pyutils/
│           └── lua_env.py
├── sddm/                   # Tema SDDM Violet Noir (opt-in)
│   └── themes/violet-noir-sddm/
└── patches/                # Documentación de parches
    └── README.md
```

## Licencia

MIT
