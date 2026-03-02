(module mods.tools.illuminate {autoload {illuminate illuminate}})

(illuminate.configure {:providers [:lsp :regex]
                       :delay 100
                       :under_cursor true})
