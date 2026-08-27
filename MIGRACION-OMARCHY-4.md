# Migrar la configuracion de Omarchy 3.x a 4 (quattro)

Procedimiento seguido en el escritorio el **27/08/2026**, sobre Omarchy
`4.0.0.r1791`, para repetirlo en la notebook.

El update a quattro **no rompe nada de forma visible**: el escritorio arranca y
se ve bien. Lo que pasa es mas silencioso — la configuracion propia deja de
tener efecto, sin un solo error en pantalla.

## Que cambio, y por que la config vieja queda muda

Hyprland paso de `.conf` a **Lua**. El update crea `~/.config/hypr/*.lua` con
los defaults (todo comentado) y `hyprland.lua` solo hace `require` de esos
modulos. Los `.conf` viejos **siguen en el disco pero ningun proceso los lee**.

Nada avisa. La forma de detectarlo es preguntarle a Hyprland que tiene cargado:

```bash
hyprctl getoption input:kb_layout     # decia "us" aunque input.conf pedia "us,latam"
```

Ademas desaparecieron **waybar**, **mako**, **walker/elephant**, **hypridle** y
**hyprlock**: los reemplaza un unico shell de Quickshell configurado en
`~/.config/omarchy/shell.json`.

## Orden de los pasos

### 1. Actualizar

```bash
omarchy update
```

> Si se corta en las migraciones, revisar `~/.config/chromium/Singleton*`: un
> lock huerfano finge un navegador abierto y aborta la migracion `copy-url`.
> Borrar esos `Singleton*` y correr `omarchy-migrate`.

El update deja backups con el sufijo `.omarchy-upgrade-to-quattro.<fecha>.bak`
en `~/.config` y en `~/.local/share/omarchy…`. Conviene no borrarlos hasta
terminar: sirven para comparar contra la config vieja.

### 2. Traer los dotfiles ya migrados

```bash
yadm pull
yadm checkout ~
yadm alt
```

Verificar que el alternate quedo bien apuntado:

```bash
readlink ~/.config/hypr/local.lua     # -> local.lua##class.laptop
```

### 3. Lo que ya no vive en un dotfile

Omarchy 4 guarda estas dos en el estado del sistema. `bootstrap.sh` las corre;
a mano son:

```bash
omarchy default terminal ghostty

sudo localectl --no-convert set-x11-keymap "us,latam" "pc105+inet" "" "terminate:ctrl_alt_bksp"
```

El layout se lee de `/etc/vconsole.conf` (`XKBLAYOUT`). Omarchy **no** hereda
`XKBOPTIONS` de ahi, por eso el toggle vive en `hypr/input.lua`. Se alterna con
**Alt izquierdo + Alt derecho**, y el widget de la barra tambien lo cicla al
click.

### 4. Borrar la config muerta

Ya no la lee nadie, y confunde al buscar por que algo no anda:

```bash
cd ~/.config/hypr
rm hyprland.conf bindings.conf input.conf looknfeel.conf autostart.conf \
   monitors.conf envs.conf hypridle.conf hyprlock.conf
rm local.conf 'local.conf##class.desktop' 'local.conf##class.laptop'
```

Sobreviven solo dos `.conf`, porque los leen **otros** procesos y no Hyprland:
`hyprsunset.conf` (night light) y `xdph.conf` (portal de screen sharing).

> Ojo con `local.conf`: si `yadm alt` corre antes de que el borrado este
> staged, recrea el symlink apuntando a un archivo que ya no existe. Queda un
> enlace roto que hay que borrar de nuevo.

### 5. Verificar

```bash
hyprctl reload && hyprctl configerrors      # tiene que salir vacio

hyprctl getoption input:kb_layout           # us,latam
hyprctl getoption input:kb_options          # ...,grp:alts_toggle
hyprctl getoption group:groupbar:height     # 0
hyprctl getoption cursor:warp_on_change_workspace   # 0

omarchy menu keybindings --print | grep -E "SUPER \+ (Q|H|J|K|L|B|TAB)"
```

Las apps de autostart **no arrancan con un `hyprctl reload`**: el hook es
`hyprland.start`, o sea el proximo login.

## Lo que NO hay que portar

Cada uno de estos tiene equivalente nativo en 4, mejor que el hack de 3.x:

| Config vieja | Que hacer en 4 |
|---|---|
| `exec-once = pkill fcitx5` | **No portarlo.** Ahora hay `omarchy-fcitx5.service`, deliberado, que da las secuencias de `~/.XCompose`. Matarlo rompe la tecla compose. |
| Script propio de brillo DDC/CI | `omarchy-brightness-display` es nativo: si el monitor no es `eDP`/`LVDS`/`DSI` usa ddcutil solo, con OSD. |
| Reglas JetBrains (`tag jb`, `stay_focused`, `no_initial_focus`) | Ya viene `o.window("^(jetbrains-.*)$", { no_follow_mouse = true })`. |
| Colores de borde de grupo hardcodeados | El default ya los toma del tema activo. |
| `~/.config/xdg-terminals.list` | `omarchy default terminal ghostty`. |
| `hypridle.conf` / `hyprlock.conf` | Esos programas ya no existen; el idle vive en `shell.json` (`idle.lock`, `idle.screensaver`). |
| `omarchy-toggle-waybar` | Se llama `omarchy-toggle-bar`. |

## La API Lua, en corto

Esta en `$OMARCHY_PATH/default/hypr/helpers.lua`, y los defaults son el mejor
ejemplo: `default/hypr/bindings/*.lua`, `apps/*.lua`, `looknfeel.lua`.

```lua
hl.config({ input = { repeat_delay = 600 } })          -- opciones de Hyprland
o.window("com.mitchellh.ghostty", { group = "set" })   -- reglas de ventana
o.bind("SUPER + Q", "Close", hl.dsp.window.close())    -- atajo
hl.unbind("SUPER + W")                                 -- liberar una tecla
o.bind_toggle("SUPER + B", "Toggle top bar", "bar")    -- llama a omarchy-toggle-<x>
o.launch_on_start("spotify")                           -- autostart (envuelve en uwsm-app)
hl.monitor({ output = "DP-2", mode = "preferred", scale = 1.25 })
```

Dos reglas que ahorran tiempo:

- **Toda tecla que Omarchy ya use necesita `hl.unbind()` antes del `o.bind()`.**
  `hl.unbind` saca *todos* los binds de esa tecla: `ALT + TAB` tenia dos en el
  default y se fueron los dos.
- Para un modulo que puede no existir (como el `local.lua` de yadm), la forma
  correcta es `require("default.hypr.require_optional").module("hypr.local")`,
  no un `require` pelado.

## Trampa aparte: `bash: hash: hashing disabled`

Aparece en cada terminal nueva y **no la causa el update** — el `set +h` de
Omarchy ("Ensure command hashing is off for mise") ya estaba en 3.x. El choque
es con **nvm**, que hace `hash -r` al cargar.

Si `node` lo provee mise, nvm no esta haciendo nada: se saca del `.bashrc` y el
mensaje desaparece. Para confirmar quien gana:

```bash
type -a node
```

Para rastrear cualquier otro ruido del arranque del shell:

```bash
PS4='+ ${BASH_SOURCE}:${LINENO}: ' bash -ixc 'exit' 2>&1 | grep -B6 "<el mensaje>"
```

## Limite conocido

La barra de 4 trae **8 widgets** y ninguno es de sistema: no hay forma de
reponer los `cpu` / `memory` / `disk` que tenia waybar sin escribir un plugin
propio de Quickshell.

```bash
ls /usr/share/omarchy/shell/plugins/bar/widgets/
```
