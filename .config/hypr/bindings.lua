-- Overrides personales de teclas.
--
-- Toda tecla que ya usa Omarchy necesita un hl.unbind() antes del o.bind().
-- Ver las teclas actuales con:  omarchy menu keybindings --print

-- ── Cerrar ventana con SUPER + Q ────────────────────────────────────────────
-- Omarchy cierra con SUPER + W; se libera esa tecla, como en la config vieja.
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close active window", hl.dsp.window.close())

-- ── Mover el foco con HJKL ──────────────────────────────────────────────────
-- Las flechas de Omarchy (SUPER + LEFT/RIGHT/UP/DOWN) siguen funcionando.
-- Piso tres defaults:
--   SUPER + J  era "Toggle window split"      -> pasa a SUPER + SHIFT + J
--   SUPER + K  era "Keybindings"              -> pasa a SUPER + SHIFT + K
--   SUPER + L  era "Toggle workspace layout"  -> queda en el menu de toggles
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
o.bind("SUPER + H", "Move focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Move focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Move focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Move focus right", hl.dsp.focus({ direction = "r" }))

-- Los dos defaults que quedaron sin tecla, reubicados.
o.bind("SUPER + SHIFT + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + SHIFT + K", "Keybindings", "omarchy-menu-keybindings")

-- ── Full width con SUPER + TAB ──────────────────────────────────────────────
-- Reemplaza al ciclado progresivo de workspaces, que no uso. Los workspaces
-- siguen en SUPER + 1..0, y el anterior/siguiente en SUPER + SHIFT/CTRL + TAB.
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- ── ALT + TAB cicla dentro del grupo ────────────────────────────────────────
-- Omarchy ya trae esto en SUPER + ALT + TAB; aca solo se le cambia la tecla,
-- usando los mismos dispatchers. El default de ALT + TAB (recorrer todas las
-- ventanas del workspace) se reemplaza.
hl.unbind("ALT + TAB")
hl.unbind("ALT + SHIFT + TAB")
o.bind("ALT + TAB", "Next window in group", hl.dsp.group.next())
o.bind("ALT + SHIFT + TAB", "Previous window in group", hl.dsp.group.prev())

-- ── Barra ───────────────────────────────────────────────────────────────────
-- Se suma a SUPER + SHIFT + SPACE, que sigue siendo el default de Omarchy.
o.bind_toggle("SUPER + B", "Toggle top bar", "bar")

-- ── Obsidian ────────────────────────────────────────────────────────────────
-- El default de Omarchy busca la ventana con "^obsidian$", pero Obsidian paso
-- su app-id a md.obsidian.Obsidian y ese patron ya no la encuentra, asi que
-- lanzaba en lugar de enfocar. El workspace lo fija hypr/windows.lua.
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "obsidian" })

-- ── Gestor de contraseñas ───────────────────────────────────────────────────
-- Omarchy apunta SUPER + SHIFT + / a 1Password, que no esta instalado en
-- ninguna de las dos maquinas: el gestor es Bitwarden.
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden-desktop", focus = "Bitwarden" })
