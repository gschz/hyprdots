# hyprdots

Configuración personal de HyDE/Hyprland para Arch Linux.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/652f4e1c-6e44-44a9-954d-24092ef7da3a" />

## Prerrequisitos

| Requisito  | Versión          | Propósito                      |
| ---------- | ---------------- | ------------------------------ |
| Arch Linux | Actual           | SO objetivo                    |
| HyDE       | Latest (post-RC) | Framework base                 |
| GNU Stow   | 2.x              | Gestión de symlinks            |
| git-lfs    | 3.x              | Almacenamiento de wallpapers   |
| Hyprland   | 0.56.x           | Compositor                     |
| hyprglass  | 0.8.0+           | Plugin de cristal (via hyprpm) |

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

## Parches HyDE

Los archivos en `local-lib/` son versiones parcheadas de scripts upstream de HyDE:

| Archivo        | Modificación                                                  |
| -------------- | ------------------------------------------------------------- |
| `color.set.sh` | Variables dcol_rgb extendidas, sed de reemplazo mejorado      |
| `reload.py`    | Targets `python`, `lua`, `cache`, `theme` + manejo de errores |
| `lua_env.py`   | Gestor de entorno Lua con luarocks del sistema                |

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
└── patches/                # Documentación de parches
    └── README.md
```

## Licencia

MIT
