(module mods.tools.gitsigns {autoload {gitsigns gitsigns}})

(vim.api.nvim_set_hl 0 :GitSignsAdd           {:link :GitSignsAdd})
(vim.api.nvim_set_hl 0 :GitSignsChange        {:link :GitSignsChange})
(vim.api.nvim_set_hl 0 :GitSignsChangeDelete  {:link :GitSignsChangeDelete})
(vim.api.nvim_set_hl 0 :GitSignsDelete        {:link :GitSignsDelete})
(vim.api.nvim_set_hl 0 :GitSignsTopDelete     {:link :GitSignsTopDelete})

(gitsigns.setup {:signs {:add           {:text "+"}
                         :change        {:text "~"}
                         :changedelete  {:text "~"}
                         :delete        {:text "-"}
                         :topdelete     {:text "-"}}
                 :current_line_blame_formatter "\t\t<author> | <author_time:%a %d/%m/%y %X> | <summary> "
                 :current_line_blame false})

(map [:n] :<leader>gb gitsigns.toggle_current_line_blame  {:desc "Toggle git blame line"})
(map [:n] :<space>gb  gitsigns.toggle_current_line_blame  {:desc "Toggle git blame line"})
