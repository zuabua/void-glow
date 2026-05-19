-- VOID GLOW — Neovim colorscheme
-- Tokyonight base, core colors overridden to ~/.config/theme/colors.sh
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night", -- darkest tokyonight variant
      transparent = false,
      on_colors = function(colors)
        -- Map tokyonight's semantic slots onto Void Glow palette
        colors.bg = "#0d0d0f" -- VOID_BASE    — editor background
        colors.bg_dark = "#0d0d0f" -- VOID_BASE
        colors.bg_float = "#131318" -- VOID_SURFACE — floating windows
        colors.bg_popup = "#131318" -- VOID_SURFACE
        colors.bg_sidebar = "#131318" -- VOID_SURFACE — file tree
        colors.bg_statusline = "#131318" -- VOID_SURFACE
        colors.bg_visual = "#1c1c24" -- VOID_OVERLAY — selection
        colors.fg = "#e2e8f0" -- VOID_TEXT
        colors.fg_dark = "#64748b" -- VOID_SUBTEXT
        colors.fg_gutter = "#1c1c24" -- VOID_OVERLAY — line-number column
        colors.comment = "#64748b" -- VOID_SUBTEXT — comments muted
        colors.cyan = "#5eead4" -- VOID_ACCENT_TEAL
        colors.teal = "#5eead4" -- VOID_ACCENT_TEAL
        colors.green = "#5eead4" -- VOID_ACCENT_TEAL (no green in palette)
        colors.blue = "#818cf8" -- VOID_ACCENT_INDIGO
        colors.purple = "#818cf8" -- VOID_ACCENT_INDIGO
        colors.magenta = "#818cf8" -- VOID_ACCENT_INDIGO
        colors.yellow = "#818cf8" -- VOID_ACCENT_INDIGO (no yellow)
        colors.orange = "#818cf8" -- VOID_ACCENT_INDIGO
        colors.red = "#f87171" -- VOID_RED
        colors.error = "#f87171" -- VOID_RED — diagnostics
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight", -- tell LazyVim to use it
    },
  },
}
