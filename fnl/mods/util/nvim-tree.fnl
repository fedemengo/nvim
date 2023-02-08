(module mods.util.nvim-tree
  {autoload {
    tree nvim-tree
    api nvim-tree.api}})

(tree.setup)

(map ["n"] "<leader>nn" api.tree.toggle {:desc "Toggle NvimTree"} )

