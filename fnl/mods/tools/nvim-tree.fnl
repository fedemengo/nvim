(module mods.tools.nvim-tree
  {autoload {
    tree nvim-tree
    api nvim-tree.api}})

(tree.setup)

(map [:n :i] :<leader>nn api.tree.toggle {:desc "Toggle NvimTree"} )

