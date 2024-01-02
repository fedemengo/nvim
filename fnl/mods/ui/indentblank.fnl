(module mods.util.indentblanck {autoload {indentblanckline ibl}})

(indentblanckline.setup {:exclude {:filetypes [:startify :TelescopePrompt]
                                    :buftypes [:terminal :nofile]}})
