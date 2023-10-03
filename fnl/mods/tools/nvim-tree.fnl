(module :mods.tools.nvim-tree
        {autoload {log :mods/dev/log tree :nvim-tree api :nvim-tree.api}})

(log.setup {:outfile :/tmp/nvim.log :color true :level :trace})

(set nvim-tree (require :nvim-tree))

(log.trace "Loading nvimtree" nvim-tree)

(nvim-tree.setup {:on_attach (fn [bufnr]
                               (log.trace "NvimTree attached")
                               (map [:n :i] :<leader>nn api.tree.toggle
                                    {:desc "Toggle NvimTree"}))})

;;(when (vim.fn.has :autocmd)
;;  (let [group (vim.api.nvim_create_augroup :filetype-mappings {:clear true})]
;;    (vim.api.nvim_create_autocmd :FileType
;;                                 {: group
;;                                  :pattern "NvimTree"
;;                                  :callback (fn []
;;                                    (unmap [:n :i] :F))})))
