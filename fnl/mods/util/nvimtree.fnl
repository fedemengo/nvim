(module mods.util.nvimtree)

(set vim.g.loaded_netrw 1)
(set vim.g.loaded_netrwPlugin 1)

(let [nvimtree (require :nvim-tree)]
  (nvimtree.setup))

