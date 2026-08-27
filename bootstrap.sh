#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# bootstrap.sh — aplica los dotfiles de ramage en una maquina Omarchy.
#
#   curl -fsSL https://raw.githubusercontent.com/ramagepe/dotfiles/master/bootstrap.sh | bash
#
# Detecta solo si es notebook o escritorio (por la presencia de bateria) y
# materializa la configuracion que corresponde. Es idempotente: se puede
# correr las veces que haga falta.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
cd "$HOME" || exit 1   # con `curl | bash` el cwd puede ser cualquiera

REPO="https://github.com/ramagepe/dotfiles.git"
BOLD=$'\e[1m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'; OFF=$'\e[0m'

say()  { printf '\n%s==>%s %s\n' "$GREEN$BOLD" "$OFF$BOLD" "$1$OFF"; }
warn() { printf '%s !%s %s\n' "$YELLOW$BOLD" "$OFF" "$1"; }
die()  { printf '\n%sABORTA:%s %s\n' "$RED$BOLD" "$OFF" "$1" >&2; exit 1; }

# ── 1 · Requisitos ───────────────────────────────────────────────────────────
say "Verificando requisitos"
[[ -f /etc/arch-release ]] || die "esto es para Arch/Omarchy."
if ! command -v yadm &>/dev/null; then
  warn "yadm no esta instalado, instalandolo"
  sudo pacman -S --needed --noconfirm yadm || die "no pude instalar yadm"
fi
echo "   yadm $(yadm version | awk '/yadm version/{print $3}')"

# ── 2 · Detectar que maquina es ──────────────────────────────────────────────
say "Detectando el tipo de maquina"
if compgen -G "/sys/class/power_supply/BAT*" >/dev/null; then
  CLASS=laptop
  echo "   bateria detectada -> ${BOLD}laptop${OFF}"
else
  CLASS=desktop
  echo "   sin bateria -> ${BOLD}desktop${OFF}"
fi
echo "   hostname: $(hostnamectl --static 2>/dev/null || hostname)"

# ── 3 · Backup de lo que se va a pisar ───────────────────────────────────────
say "Respaldando la configuracion actual"
TS=$(date +%Y%m%d-%H%M%S)
BACKUP="$HOME/.config-backup-$TS"
mkdir -p "$BACKUP"
for d in hypr omarchy alacritty ghostty kitty; do
  [[ -d "$HOME/.config/$d" ]] && cp -r "$HOME/.config/$d" "$BACKUP/" 2>/dev/null
done
echo "   copia en: $BACKUP"

# ── 4 · Traer el repo ────────────────────────────────────────────────────────
if [[ -d "$HOME/.local/share/yadm/repo.git" ]]; then
  say "El repo ya existe: actualizando"
  yadm pull --rebase || warn "no pude hacer pull; sigo con lo que hay local"
else
  say "Clonando los dotfiles"
  # OJO: yadm clone NO pisa archivos existentes, solo imprime un NOTE.
  # Por eso el checkout del paso 6 es obligatorio.
  yadm clone -f "$REPO" || die "fallo el clone"
fi

# ── 5 · Definir la clase ANTES de resolver los alternates ────────────────────
say "Configurando la clase de esta maquina"
yadm config local.class "$CLASS"
echo "   local.class = $(yadm config local.class)"

# ── 6 · Materializar los archivos (el paso que siempre se olvida) ────────────
say "Aplicando los dotfiles"
yadm checkout -- "$HOME" 2>/dev/null || yadm checkout "$HOME" || die "fallo el checkout"
yadm alt
echo "   local.lua -> $(readlink -f "$HOME/.config/hypr/local.lua" 2>/dev/null | xargs -r basename)"

# ── 7 · Ajustes que en Omarchy 4 no viven en un dotfile ──────────────────────
# Estos dos los guarda el sistema, no el repo: hay que pedirlos por comando.
say "Aplicando preferencias del sistema"

# Terminal por defecto de xdg-terminal-exec (antes: ~/.config/xdg-terminals.list)
if command -v ghostty &>/dev/null; then
  omarchy default terminal ghostty >/dev/null 2>&1 &&
    echo "   terminal por defecto: ghostty" ||
    warn "no pude fijar ghostty como terminal por defecto"
else
  warn "ghostty no esta instalado; el terminal por defecto queda como este"
fi

# Layout de teclado us,latam. Omarchy 4 lo lee de /etc/vconsole.conf; el toggle
# (Alt izq + Alt der) lo agrega ~/.config/hypr/input.lua.
if [[ $(. /etc/vconsole.conf 2>/dev/null; echo "${XKBLAYOUT:-}") != "us,latam" ]]; then
  sudo localectl --no-convert set-x11-keymap "us,latam" "pc105+inet" "" "terminate:ctrl_alt_bksp" &&
    echo "   layout de teclado: us,latam (Alt izq + Alt der para alternar)" ||
    warn "no pude fijar el layout de teclado"
else
  echo "   layout de teclado: us,latam"
fi

# ── 8 · Que paquetes le faltan a la configuracion ────────────────────────────
say "Paquetes que tu configuracion necesita y no estan"
DEPS="$HOME/.config/omarchy/packages-config-deps.txt"
if [[ -f $DEPS ]]; then
  MISSING=$(comm -23 \
    <(grep -v '^#' "$DEPS" | sed 's/#.*//; s/ *$//' | grep -v '^$' | sort -u) \
    <(pacman -Qqe | sort))
  if [[ -z $MISSING ]]; then
    echo "   no falta ninguno"
  else
    echo "$MISSING" | sed 's/^/   /'
    echo
    echo "   instalalos con:  omarchy pkg add $(echo $MISSING | tr '\n' ' ')"
    echo "   (los que sean de AUR: omarchy pkg aur add <paquete>)"
  fi
else
  warn "no encontre $DEPS"
fi

# ── 9 · Aplicar en caliente ──────────────────────────────────────────────────
say "Recargando"
if command -v hyprctl &>/dev/null && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  hyprctl reload >/dev/null && echo "   hyprland recargado"
  ERRORS=$(hyprctl configerrors 2>/dev/null)
  if [[ -n $ERRORS && $ERRORS != *"no errors"* ]]; then
    warn "hyprland reporta errores de configuracion:"; echo "$ERRORS"
  else
    echo "   sin errores de configuracion"
  fi
  command -v omarchy &>/dev/null && omarchy restart shell >/dev/null 2>&1 && echo "   omarchy shell reiniciado"
else
  warn "no estas dentro de Hyprland: cerra sesion y volve a entrar para aplicar todo"
fi

say "Listo"
echo "   Si algo quedo mal, tu configuracion anterior esta en:"
echo "   $BACKUP"
