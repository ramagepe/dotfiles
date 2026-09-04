# dotfiles

Configuraciones personales para [Omarchy](https://omarchy.org/) (Arch Linux + Hyprland), gestionadas con [yadm](https://yadm.io/).

> Puestas al dia para **Omarchy 4 (quattro)**, que cambio la config de Hyprland de `.conf` a Lua y reemplazo Waybar, mako y walker por el shell de Quickshell.
>
> Para migrar una maquina que todavia esta en 3.x, seguir
> **[MIGRACION-OMARCHY-4.md](MIGRACION-OMARCHY-4.md)**: el update no rompe nada
> visible, pero deja la configuracion propia muda.

## Que incluye

### Hyprland
Desde Omarchy 4 la config es Lua: `hyprland.lua` carga los defaults del paquete y despues estos modulos, asi que un update puede mejorar los defaults sin pisar nada de aca.

| Archivo | Descripcion |
|---|---|
| `hypr/hyprland.lua` | Orquestador: carga los defaults de Omarchy y despues estos modulos |
| `hypr/input.lua` | Toggle de teclado us/latam (Alt izq + Alt der) y `repeat_delay` |
| `hypr/looknfeel.lua` | Tab bar de grupos oculta, auto-group de Ghostty, sin warp del cursor |
| `hypr/windows.lua` | Cada app a su workspace (zen, postman, obsidian, discord, etc.) |
| `hypr/bindings.lua` | Cerrar con SUPER+Q, foco con HJKL, full width en SUPER+TAB, ALT+TAB dentro del grupo, barra en SUPER+B |
| `hypr/autostart.lua` | Procesos extra al iniciar |
| `hypr/local.lua##class.desktop` | **Especifico del escritorio**: brillo por DDC/CI, solaar, 8 apps de autostart |
| `hypr/local.lua##class.laptop` | **Especifico de la notebook**: pantallas a 1x con el BenQ fijo a la derecha, modo "solo notebook" (Super+Ctrl+Shift+Delete), solaar para corregir el perfil onboard del G203, 5 apps de autostart, sin binds de DDC |

### Omarchy
| Archivo | Descripcion |
|---|---|
| `omarchy/shell.json` | Barra de Quickshell: layout de widgets, posicion, tiempos de idle |
| `omarchy/shell.toml` | Tamaño de fuente del shell |
| `omarchy/extensions/omarchy-menu.jsonc` | Submenu "Schedule Shutdown" en System, y modos de proyeccion (Dual / Laptop only / External only / Mirror) en Hardware |
| `omarchy/hooks/post-update.d/setup-agent.hook` | Invitacion a elegir agente por defecto tras un update |
| `omarchy/branding/about.txt` | ASCII art logo custom |
| `omarchy/branding/screensaver.txt` | Banner ASCII |

### Terminales
| Archivo | Descripcion |
|---|---|
| `alacritty/alacritty.toml` | Font size, F11 fullscreen |
| `kitty/kitty.conf` | Padding, F11 fullscreen, single instance |
| `ghostty/config` | Font size, F11 fullscreen |

### Apps
| Archivo | Descripcion |
|---|---|
| `git/config` | Identidad, pull rebase, gh credentials |
| `tmux/tmux.conf` | Tema Aura minimal, sin status bar, vim-style panes, OSC 52 |
| `herdr/config.toml` | Navegacion vim entre panes, plugins |
| `opencode/opencode.json` | Comandos custom, MCPs, permisos bash |
| `mimeapps.list` | Asociaciones: zen browser, imv, mpv |
| `gh/config.yml` | GitHub CLI: protocolo https |
| `mise/config.toml` | Node, gh y los CLIs de agentes |
| `htop/htoprc`, `zed/settings.json`, `Code/User/*` | Config de herramientas |

### Shell
| Archivo | Descripcion |
|---|---|
| `.bashrc` | Bootstrap de `OMARCHY_PATH`, NVM, Pulumi, direnv, colores de pane por proyecto |
| `.aliases` | 90+ aliases (pacman, docker, config shortcuts, rust tools, etc.) |
| `.XCompose` | Secuencias de composicion propias (Caps Lock es la tecla compose) |

### Neovim
Config completa basada en LazyVim con plugins custom (obsidian, diffview, navegacion herdr, clipboard remoto por OSC 52, etc.).

### Scripts (`~/.local/bin`)
| Archivo | Descripcion |
|---|---|
| `schedule-shutdown` | Apagado programado con un timer de systemd; se expone en el menu de Omarchy |
| `schedule-shutdown-prompt` | Dialogo para elegir las horas |
| `tmux-smooth-zoom` | Zoom de panes sin saltos |
| `monitor-external-toggle` | Apaga/prende los monitores externos (modo "solo notebook"), el caso que Omarchy no cubre |
| `power-profile-low-battery` | Tercer escalon de energia: `power-saver` con bateria baja (Omarchy solo cubre AC y bateria) |

### Systemd
| Archivo | Descripcion |
|---|---|
| `systemd/user/power-profile-low-battery.{service,timer}` | Pasa a `power-saver` con la bateria <= 20%. Habilitar con `systemctl --user enable --now power-profile-low-battery.timer` |

## Restaurar en instalacion nueva

### Forma corta (un solo comando)

Con Omarchy ya instalado:

```bash
curl -fsSL https://raw.githubusercontent.com/ramagepe/dotfiles/master/bootstrap.sh | bash
```

Eso hace todo: instala yadm si falta, **detecta solo si es notebook o escritorio** (por la presencia de bateria), respalda la config actual, clona, aplica los archivos, resuelve los alternates, fija el terminal y el layout de teclado, lista que paquetes faltan y recarga Hyprland y el shell. Es idempotente: se puede correr las veces que haga falta.

### Forma larga (paso a paso)

#### 1. Instalar Omarchy

Seguir la guia en [omarchy.org](https://omarchy.org/).

#### 2. Instalar yadm y clonar

```bash
sudo pacman -S yadm
yadm clone https://github.com/ramagepe/dotfiles.git
yadm config local.class laptop    # o 'desktop', segun la maquina
yadm checkout ~                   # <-- IMPRESCINDIBLE
yadm alt
```

> ⚠️ **`yadm clone` NO sobreescribe nada.** No pregunta: deja intactos los archivos que ya existen y solo imprime un `**NOTE**`. Como Omarchy instala sus propios defaults, un clone sobre una instalacion fresca aplica menos de un tercio del repo y termina sin error, dando la impresion de que funciono. **El `yadm checkout ~` no es opcional.**
>
> `yadm alt` resuelve los archivos `##class.*`, y solo procesa archivos ya trackeados. La clase hay que definirla **antes**, o el symlink de `local.lua` queda apuntando a la maquina equivocada.

#### 3. Preferencias que no viven en un dotfile

Omarchy 4 guarda estas dos en el estado del sistema, no en `~/.config`, asi que hay que pedirlas por comando:

```bash
# Terminal de xdg-terminal-exec (reemplaza al viejo ~/.config/xdg-terminals.list)
omarchy default terminal ghostty

# Layout de teclado: Omarchy lo lee de /etc/vconsole.conf.
# El toggle (Alt izq + Alt der) lo agrega hypr/input.lua.
sudo localectl --no-convert set-x11-keymap "us,latam" "pc105+inet" "" "terminate:ctrl_alt_bksp"
```

#### 4. Aplicar tema

```bash
omarchy theme set aura
```

#### 5. Rellenar secretos

Abrir `~/.config/opencode/opencode.json` y reemplazar los placeholders:

```
PLACEHOLDER_LINEAR_API_KEY           -> tu API key de Linear
PLACEHOLDER_MERCADOPAGO_BEARER_TOKEN -> tu Bearer token de MercadoPago
```

## Uso diario

```bash
# Ver que cambio. El -uall no es opcional: sin el, yadm es CIEGO a los untracked.
yadm status -uall
yadm diff

# Trackear un archivo nuevo o modificado. Si es nuevo, primero hay que
# abrirle la puerta en ~/.gitignore, que es una whitelist.
yadm add ~/.config/hypr/input.lua

# Commitear
yadm commit -m "descripcion del cambio"

# Subir a GitHub
yadm push

# Bajar cambios (si editas desde otra maquina)
yadm pull
```

> El `.gitignore` de este repo es una **whitelist**: ignora todo y habilita archivo por archivo. Para versionar algo nuevo hay que agregar su `!` ahi primero. A cambio, `yadm status -uall` es una lista corta y legible en vez de un volcado del home.

## Alcance

Este repo tiene **solo configuracion del sistema y del escritorio**: lo que trasciende de una maquina a otra. No es un backup del home. Quedan afuera, sin excepciones, `~/code` y cualquier espacio de trabajo (cada proyecto tiene su repo) y las credenciales de cualquier tipo — **el remoto es publico**.

## Secretos

Los siguientes valores estan reemplazados con placeholders y **nunca se commitean** con valores reales:

- `opencode.json` -> `LINEAR_API_KEY`
- `opencode.json` -> `AUTH_HEADER` (MercadoPago Bearer token)

El archivo `~/.claude.json` esta excluido completamente (contiene estado efimero + API keys).

## Archivos NO trackeados (se regeneran solos)

- Temas (`~/.config/omarchy/themes/`) — se instalan con `omarchy theme set <nombre>`
- `~/.config/hypr/local.lua` — lo materializa `yadm alt` desde el `##class.*` que corresponda
- `~/.config/hypr/monitors.lua` — estado de cada maquina; lo reescribe Omarchy al cambiar la escala (`SUPER + SLASH`). El layout de pantallas que si es propio vive en `local.lua##class.*`, que se carga despues
- `~/.config/hypr/.luarc.json` — lo genera Omarchy para el LSP de Lua
- `~/.config/xdg-terminals.list` — lo genera `omarchy default terminal`
- `hyprsunset.conf` y `xdph.conf` — identicos al default de Omarchy; trackearlos congelaria defaults viejos
- Neovim `lazy-lock.json` — se regenera al abrir nvim
- `btop.conf` — auto-regenerado por btop
