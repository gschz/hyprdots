## Parches HyDE

Estos parches modifican scripts upstream de HyDE para agregar funcionalidad personalizada.

### Parches disponibles

| Archivo        | Descripción                                                                                                                                      |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `color.set.sh` | Versión parcheada de `~/.local/lib/hyde/color.set.sh`. Agrega soporte para variables dcol_rgb y sed de reemplazo extendido.                      |
| `reload.py`    | Versión parcheada de `~/.local/lib/hyde/reload.py`. Agrega targets `python`, `lua`, `cache`, `theme` y manejo de errores mejorado.               |
| `lua_env.py`   | Versión parcheada de `~/.local/lib/hyde/pyutils/lua_env.py`. Gestor de entorno Lua con soporte para luarocks del sistema y snapshot de paquetes. |

### Cómo re-aplicar

Después de cada actualización de HyDE, ejecuta:

```bash
./reapply-patches.sh
```

Esto intentará aplicar los parches automáticamente. Si falla, revisa los archivos manualmente comparando con las versiones parcheadas en `local-lib/`.

### Archivos parcheados completos

Las versiones completas de los archivos parcheados están en `local-lib/`. `install.sh` copia estos archivos directamente a los destinos correctos durante la instalación.
