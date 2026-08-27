-- Overrides personales de entrada.
--
-- El default de Omarchy ya cubre compose:caps, repeat_rate 40, numlock,
-- touchpad scroll_factor 0.4 y el scroll por terminal, asi que no se repiten.

-- El layout de teclado sale de /etc/vconsole.conf (XKBLAYOUT=us,latam), que es
-- de donde lo lee el default de Omarchy: se cambia con `localectl`, no aca.
-- Lo unico que falta es el toggle, porque el default solo lo agrega cuando el
-- primer layout no puede escribir letras latinas (no es el caso de us,latam).
--
--   Alt izquierdo + Alt derecho  ->  alterna us <-> latam
--
-- El widget omarchy.keyboard-layout de la barra muestra el activo y tambien
-- lo cicla al hacerle click.
hl.config({
  input = {
    kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",

    -- Mas margen antes de que arranque la repeticion (default: 250).
    repeat_delay = 600,
  },
})
