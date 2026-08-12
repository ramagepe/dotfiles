# dotfiles

Configuraciones personales para [Omarchy](https://omarchy.org/) (Arch Linux + Hyprland), gestionadas con [yadm](https://yadm.io/).

## Que incluye

### Hyprland
| Archivo | Descripcion |
|---|---|
| `hypr/bindings.conf` | Vim-style HJKL, switch teclado US/LATAM (Super+Shift+Space), toggle waybar (Super+B), ALT+TAB groups |
| `hypr/autostart.conf` | Workspace assignments (zen, postman, obsidian, discord, etc.) |
| `hypr/local.conf##class.desktop` | **Especifico del escritorio**: brillo por DDC/CI, solaar, 8 apps de autostart |
| `hypr/local.conf##class.laptop` | **Especifico de la notebook**: pantallas a 1x con el BenQ fijo a la derecha, modo "solo notebook" (Super+Ctrl+Shift+Delete), solaar para corregir el perfil onboard del G203, 5 apps de autostart, sin binds de DDC |
| `hypr/input.conf` | Dual keyboard `us,latam`, reglas JetBrains IDE |
| `hypr/looknfeel.conf` | Hyprland groups con colores Dracula, tab bar oculto, auto-group Ghostty |
| `hypr/hyprland.conf` | Source de envs.conf |
| `hypr/hyprlock.conf` | Input field 450x75, fuente CaskaydiaMono |
| `hypr/envs.conf` | Variables de entorno extra |

### Waybar
| Archivo | Descripcion |
|---|---|
| `waybar/config.jsonc` | CPU, memory, disk en centro; clock con fecha; workspaces con numeros |
| `waybar/style.css` | Fuente CaskaydiaMono, indicador workspace activo |

### Terminales
| Archivo | Descripcion |
|---|---|
| `alacritty/alacritty.toml` | Font size 11.5, F11 fullscreen |
| `kitty/kitty.conf` | Padding, F11 fullscreen, single instance |
| `ghostty/config` | Font size 11, F11 fullscreen |

### Apps
| Archivo | Descripcion |
|---|---|
| `git/config` | Identidad, pull rebase, gh credentials |
| `tmux/tmux.conf` | Tema Aura minimal, sin status bar, vim-style panes |
| `mako/config` | Colores Dracula/Aura, fuente Liberation Sans 11 |
| `opencode/opencode.json` | Comandos custom, MCPs (Linear, MercadoPago, AWS, Pulumi), permisos bash |
| `mimeapps.list` | Asociaciones: zen browser, imv, mpv |
| `xdg-terminals.list` | Terminal default: Ghostty |
| `gh/config.yml` | GitHub CLI: protocolo https |
| `mise/config.toml` | Node latest |

### Shell
| Archivo | Descripcion |
|---|---|
| `.bashrc` | NVM, Pulumi, direnv, funcion tmux pane colors por proyecto |
| `.aliases` | 90+ aliases (pacman, docker, config shortcuts, rust tools, etc.) |
| `.zshrc` | LM Studio PATH |

### Neovim
Config completa basada en LazyVim con plugins custom (code-companion, lazydocker, opencode, omarchy-theme-hotreload, etc.).

### Systemd
| Archivo | Descripcion |
|---|---|
| `systemd/user/elephant.service` | Servicio Elephant |
| `systemd/user/app-walker@autostart.service.d/restart.conf` | Auto-restart walker |

### Omarchy
| Archivo | Descripcion |
|---|---|
| `omarchy/extensions/menu.sh` | Menu sistema con "Boot to Windows"; submenu de modos de proyeccion (Dual / Laptop only / External only / Mirror) en el menu de hardware |
| `omarchy/branding/about.txt` | ASCII art logo custom |
| `omarchy/branding/screensaver.txt` | Banner ASCII |

### Claude Code
| Archivo | Descripcion |
|---|---|
| `.claude/settings.json` | Modelo, plugins, permisos |
| `.claude/settings.local.json` | Permisos locales |

### Scripts
| Archivo | Descripcion |
|---|---|
| `code/scripts/boot-to-windows` | UEFI BootNext para dual-boot one-time reboot |
| `.local/bin/monitor-external-toggle` | Apaga/prende los monitores externos (modo "solo notebook"), el caso que Omarchy no cubre |

## Restaurar en instalacion nueva

### Forma corta (un solo comando)

Con Omarchy ya instalado:

```bash
curl -fsSL https://raw.githubusercontent.com/ramagepe/dotfiles/master/bootstrap.sh | bash
```

Eso hace todo: instala yadm si falta, **detecta solo si es notebook o escritorio** (por la presencia de bateria), respalda la config actual, clona, aplica los archivos, resuelve los alternates, lista que paquetes faltan y recarga Hyprland y Waybar. Es idempotente: se puede correr las veces que haga falta.

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
> `yadm alt` resuelve los archivos `##class.*`, y solo procesa archivos ya trackeados. La clase hay que definirla **antes**, o el symlink de `local.conf` queda apuntando a la maquina equivocada.

### 3. Aplicar tema

```bash
omarchy-theme-set aura
```

### 4. Rellenar secretos

Abrir `~/.config/opencode/opencode.json` y reemplazar los placeholders:

```
PLACEHOLDER_LINEAR_API_KEY       -> tu API key de Linear
PLACEHOLDER_MERCADOPAGO_BEARER_TOKEN -> tu Bearer token de MercadoPago
```

### 5. Recargar servicios

```bash
systemctl --user daemon-reload
systemctl --user enable --now elephant.service
```

## Uso diario

```bash
# Ver que cambio
yadm status
yadm diff

# Trackear un archivo nuevo o modificado
yadm add ~/.config/hypr/bindings.conf

# Commitear
yadm commit -m "descripcion del cambio"

# Subir a GitHub
yadm push

# Bajar cambios (si editas desde otra maquina)
yadm pull
```

## Secretos

Los siguientes valores estan reemplazados con placeholders y **nunca se commitean** con valores reales:

- `opencode.json` -> `LINEAR_API_KEY`
- `opencode.json` -> `AUTH_HEADER` (MercadoPago Bearer token)

El archivo `~/.claude.json` esta excluido completamente (contiene estado efimero + API keys).

## Archivos NO trackeados (se regeneran solos)

- Tema aura (`~/.config/omarchy/themes/aura/`) - se instala con `omarchy-theme-set aura`
- Neovim lazy-lock.json - se regenera al abrir nvim
- Configs default de Omarchy que no fueron modificados (walker, lazygit, starship, etc.)
- btop.conf - auto-regenerado por btop
