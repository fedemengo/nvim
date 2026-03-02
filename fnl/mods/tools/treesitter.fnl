(module mods.tools.treesitter {autoload {treesitter nvim-treesitter}})

(local parsers [:commonlisp
                :fennel
                :go
                :gomod
                :gowork
                :cpp
                :python
                :lua
                :vim
                :vimdoc
                :bash
                :gitcommit
                :gitignore
                :make
                :diff
                :dockerfile
                :yaml
                :json])

(fn is-large-file [_ bufnr]
  (or (> (vim.fn.getfsize (vim.fn.bufname bufnr)) (* 1024 1024))
      ; 1MB is rarely source code
      (> (vim.api.nvim_buf_line_count bufnr) 5000)))

(fn is-filetype [ft _]
  (case ft [:python] true _ false))

(fn disable-indent [ft bufnr]
  (or (is-large-file ft bufnr) (is-filetype ft bufnr)))

(fn maybe-start-highlighter [bufnr]
  (when (not (is-large-file nil bufnr))
    (vim.api.nvim_buf_call bufnr
                           (fn []
                             (pcall vim.treesitter.start)))))

(treesitter.setup)
(treesitter.install parsers)

(vim.api.nvim_create_autocmd :FileType
                             {:group (vim.api.nvim_create_augroup :treesitter
                                                                  {:clear true})
                              :callback (fn [ev]
                                          (let [bufnr (. ev :buf)
                                                ft (vim.api.nvim_get_option_value :filetype
                                                                                  {:buf bufnr})
                                                indentexpr "v:lua.require'nvim-treesitter'.indentexpr()"]
                                            (maybe-start-highlighter bufnr)
                                            (if (disable-indent ft bufnr)
                                                (when (= (vim.api.nvim_get_option_value :indentexpr
                                                                                         {:buf bufnr})
                                                         indentexpr)
                                                  (vim.api.nvim_set_option_value :indentexpr
                                                                                 ""
                                                                                 {:buf bufnr}))
                                                (vim.api.nvim_set_option_value :indentexpr
                                                                               indentexpr
                                                                               {:buf bufnr}))))})
