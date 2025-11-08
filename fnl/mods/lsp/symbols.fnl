(module :mods.lsp.symbols {autoload {outline :outline}})

(outline.setup {:relative_width true :width 40})

(map [:n] :<space>s outline.toggle_outline
     {:desc "Toggle symbols outline"})
