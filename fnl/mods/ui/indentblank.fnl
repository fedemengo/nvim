(module mods.util.indentblanck {
  autoload {
    indentblanckline indent_blankline }})

(set vim.g.indent_blankline_buftype_exclude [ "terminal" "nofile" ])
(set vim.g.indent_blankline_filetype_exclude ["startify" "TelescopePrompt"])

(indentblanckline.setup)

