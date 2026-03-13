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
