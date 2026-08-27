return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory", "DiffviewRefresh" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: cambios sin commitear" },
    { "<leader>gD", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Diffview: vs último commit" },
    { "<leader>gv", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: historial del archivo" },
    { "<leader>gV", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: historial del repo" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: cerrar" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = { layout = "diff2_horizontal" },
      merge_tool = { layout = "diff3_mixed", disable_diagnostics = true },
    },
    file_panel = {
      listing_style = "tree",
      win_config = { position = "left", width = 32 },
    },
  },
}
