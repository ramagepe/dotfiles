# dotfiles

Configuraciones personales para [Omarchy](https://omarchy.org/) (Arch Linux + Hyprland), gestionadas con [yadm](https://yadm.io/).

## Que incluye

### Hyprland
| Archivo | Descripcion |
|---|---|
| `hypr/bindings.conf` | Vim-style HJKL, switch teclado US/LATAM (Super+Shift+Space), toggle waybar (Super+B), ALT+TAB groups |
| `hypr/autostart.conf` | Workspace assignments (zen, postman, obsidian, discord, etc.), auto-start 8 apps |
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
| `omarchy/extensions/menu.sh` | Menu sistema con "Boot to Windows" |
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

## Restaurar en instalacion nueva

### 1. Instalar Omarchy

Seguir la guia en [omarchy.org](https://omarchy.org/).

### 2. Instalar yadm y clonar

```bash
sudo pacman -S yadm
yadm clone https://github.com/ramagepe/dotfiles.git
```

yadm va a preguntar si queres sobreescribir archivos existentes. Decir **Y** (si) para reemplazar los defaults de Omarchy con tus customizaciones.

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
