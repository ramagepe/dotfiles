-- vim-herdr-navigation — puente Neovim ↔ herdr
--
-- Ctrl+h/j/k/l se mueve entre splits de Neovim y, al llegar a un borde, cruza
-- al pane vecino de herdr. Fuera de herdr cae a tmux o a wincmd plano.
--
-- Vive en after/plugin/ a propósito: se carga después de todos los plugins y
-- así le gana a los mapeos <C-h/j/k/l> que LazyVim trae por defecto.
--
-- La ruta del plugin lleva un hash de instalación que cambia al reinstalarlo,
-- por eso se resuelve por glob en vez de hardcodearla.

local matches = vim.fn.glob(
  vim.fn.expand("~/.config/herdr/plugins/github/vim-herdr-navigation-*/editor/nvim.lua"),
  false,
  true
)

if #matches == 0 then
  -- El plugin no está instalado (o cambió de nombre). Silencio en vez de
  -- error: LazyVim ya mapea C-hjkl a wincmd, así que se degrada solo.
  return
end

dofile(matches[1])
