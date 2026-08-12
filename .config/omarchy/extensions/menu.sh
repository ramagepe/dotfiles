# Omarchy menu extensions
# This file is sourced by omarchy-menu and can override any function defined there.

# Override show_system_menu to add "Boot to Windows" option
show_system_menu() {
  local options="󱄄  Screensaver\n  Lock"
  [[ ! -f ~/.local/state/omarchy/toggles/suspend-off ]] && options="$options\n󰌲  Suspend"
  omarchy-hibernation-available && options="$options\n󰤁  Hibernate"
  options="$options\n󰍃  Logout\n  Boot to Windows\n󰜉  Restart\n󰐥  Shutdown"

  case $(menu "System" "$options") in
  *Screensaver*) omarchy-launch-screensaver force ;;
  *Lock*) omarchy-lock-screen ;;
  *Suspend*) systemctl suspend ;;
  *Hibernate*) systemctl hibernate ;;
  *Logout*) omarchy-system-logout ;;
  *"Boot to Windows"*) present_terminal "$HOME/code/scripts/boot-to-windows" ;;
  *Restart*) omarchy-system-reboot ;;
  *Shutdown*) omarchy-system-shutdown ;;
  *) back_to show_main_menu ;;
  esac
}

# ── Modos de proyeccion ───────────────────────────────────────────────────────
# Omarchy expone dos toggles sueltos en el menu de hardware ("Laptop Display" y
# "Mirror Display"), que obligan a deducir que va a hacer cada uno segun el
# estado actual. Cuando hay un monitor externo conectado los reemplazamos por un
# submenu con los cuatro modos nombrados, para elegir el que se quiere y listo.
#
# El modo activo se detecta por los flags de toggle de Hyprland y se pasa como
# preseleccion, asi el menu abre parado sobre el modo en el que ya estas.

OMARCHY_HYPR_TOGGLES="$HOME/.local/state/omarchy/toggles/hypr"

# Este archivo lo comparten las dos maquinas (no tiene alternate de yadm), asi
# que los modos de proyeccion tienen que aparecer solo donde tienen sentido: en
# el escritorio no hay panel interno, y "External only" terminaria pidiendole a
# omarchy-hyprland-monitor-internal que apague un eDP que no existe.
has_internal_display() {
  local status
  for status in /sys/class/drm/card*-eDP-*/status; do
    [[ -r $status ]] || continue
    [[ "$(<"$status")" == connected ]] && return 0
  done
  return 1
}

current_display_mode() {
  if [[ -f "$OMARCHY_HYPR_TOGGLES/internal-monitor-mirror.conf" ]]; then
    echo "󰆏  Mirror"
  elif [[ -f "$OMARCHY_HYPR_TOGGLES/internal-monitor-disable.conf" ]]; then
    echo "󰍹  External only"
  elif [[ -f "$OMARCHY_HYPR_TOGGLES/external-monitor-disable.conf" ]]; then
    echo "󰛧  Laptop only"
  else
    echo "󰍺  Dual"
  fi
}

show_display_mode_menu() {
  local options="󰍺  Dual\n󰛧  Laptop only\n󰍹  External only\n󰆏  Mirror"

  # Cada modo se arma desde cualquier estado anterior, por eso se apagan los
  # otros dos toggles antes. Los comandos son idempotentes y silenciosos cuando
  # ya estan en el estado pedido, asi que encadenarlos no genera ruido.
  case $(menu "Display" "$options" "" "$(current_display_mode)") in
  *Dual*)
    omarchy-hyprland-monitor-internal-mirror off
    monitor-external-toggle on
    omarchy-hyprland-monitor-internal on
    ;;
  *"Laptop only"*)
    omarchy-hyprland-monitor-internal-mirror off
    omarchy-hyprland-monitor-internal on
    monitor-external-toggle off
    ;;
  *"External only"*)
    omarchy-hyprland-monitor-internal-mirror off
    monitor-external-toggle on
    omarchy-hyprland-monitor-internal off
    ;;
  *Mirror*)
    monitor-external-toggle on
    omarchy-hyprland-monitor-internal-mirror on
    ;;
  *) back_to show_hardware_menu ;;
  esac
}

# Override show_hardware_menu para colgar ahi el submenu de modos.
# El resto de las entradas es una copia de las de Omarchy: si upstream agrega
# alguna, hay que reflejarla aca.
show_hardware_menu() {
  local options=""

  # Sin panel interno (el escritorio) no se ofrece ninguna entrada de pantalla.
  # Las dos que trae Omarchy resuelven el monitor interno por nombre y, sin eDP,
  # el nombre queda vacio: terminan escribiendo `monitor=,disable`, que en
  # Hyprland es la regla catch-all y apaga todas las pantallas.
  if has_internal_display; then
    if omarchy-hw-external-monitors; then
      options="󰍺  Displays"
    else
      # Sin monitor externo los cuatro modos no aplican: menu original.
      options="󰛧  Laptop Display\n 󰍹  Mirror Display"
    fi
  fi

  if omarchy-hw-hybrid-gpu; then
    options="$options\n  Hybrid GPU"
  fi

  if omarchy-hw-touchpad; then
    options="$options\n󰟸  Touchpad"
  fi

  if omarchy-hw-dell-xps-haptic-touchpad && omarchy-cmd-present dell-xps-touchpad-haptics; then
    options="$options\n󰌌  Touchpad Haptics"
  fi

  if omarchy-hw-touchscreen; then
    options="$options\n󰆽  Touchscreen"
  fi

  # El bloque de pantallas puede no haber aportado nada: sacamos el separador
  # inicial para que el menu no abra con una linea en blanco.
  options=${options#\\n}

  case $(menu "Toggle" "$options") in
  *Displays*) show_display_mode_menu ;;
  *Laptop*) omarchy-hyprland-monitor-internal toggle ;;
  *Mirror*) omarchy-hyprland-monitor-internal-mirror toggle ;;
  *Haptics*) show_hardware_touchpad_haptics_menu ;;
  *Touchpad*) omarchy-toggle-touchpad ;;
  *Touchscreen*) omarchy-toggle-touchscreen ;;
  *"Hybrid GPU"*) present_terminal omarchy-toggle-hybrid-gpu ;;
  *) back_to show_trigger_menu ;;
  esac
}
