(module mods.ui.indentblank {autoload {ibl ibl}})

(ibl.setup {:exclude {:filetypes [:startify :TelescopePrompt]
                      :buftypes [:terminal :nofile]}})
