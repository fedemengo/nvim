(module mods.tools.treesitter {autoload {conf nvim-treesitter.configs}})

(fn is-large-file [_ bufnr]
  (or (> (vim.fn.getfsize (vim.fn.bufname bufnr)) (* 1024 1024))
      ; 1MB is rarely source code
      (> (vim.api.nvim_buf_line_count bufnr) 5000)))

(fn is-filetype [ft _]
  (case ft [:python] true _ false))

(fn disable-indent [ft bufnr]
  (or (is-large-file ft bufnr) (is-filetype ft bufnr)))

(conf.setup {:ensure_installed [:commonlisp
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
                                :json]
             :sync_install false
             :indent {:enable true :disable disable-indent}
             :highlight {:enable true
                         :disable is-large-file
                         :additional_vim_regex_highlighting false}})
