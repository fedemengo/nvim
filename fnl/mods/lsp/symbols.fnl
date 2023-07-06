(module :mods.lsp.symbols {autoload {symbols-outline :symbols-outline}})

(symbols-outline.setup {:relative_width true :width 40})

(map [:n] :<space>s symbols-outline.toggle_outline
     {:desc "Toggle symbols outline"})
