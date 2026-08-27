-- Overrides personales del look'n'feel.
--
-- Los colores de borde de grupo ya salen del tema activo en el default de
-- Omarchy 4, asi que no hace falta fijarlos a mano como en la config vieja.

hl.config({
  group = {
    groupbar = {
      -- Ocultar la barra de tabs de los grupos: las ventanas agrupadas se ven
      -- como una sola, sin titulos ni indicador arriba.
      height = 0,
      indicator_height = 0,
    },
  },

  cursor = {
    -- No teletransportar el puntero al centro al cambiar de workspace.
    warp_on_change_workspace = 0,
  },
})

-- Agrupar automaticamente las terminales Ghostty entre si.
o.window("com.mitchellh.ghostty", { group = "set" })
