(module mods.util.indentblanck)

(let [autopairs (require :indent_blankline)]
  (set vim.g.indent_blankline_buftype_exclude [ "terminal" "nofile" ])
  (set vim.g.indent_blankline_filetype_exclude ["startify" "TelescopePrompt"])
)

