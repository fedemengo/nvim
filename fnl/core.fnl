(module :core)

;; autocmd
(when (vim.fn.has :autocmd)
  (let [g (vim.api.nvim_create_augroup :misc {:clear true})]
    ;; restore cursor last position in filesilent since for new file would error
    (vim.api.nvim_create_autocmd :BufReadPost
                                 {:group g
                                  :pattern "*"
                                  :callback (fn []
                                              (when (<= (vim.fn.line "'\"")
                                                        (vim.fn.line "$"))
                                                (vim.fn.execute "normal! g`\"")))})
    ;; switch off relative number in insert mode
    (vim.api.nvim_create_autocmd :InsertEnter
                                 {:group g :command "set norelativenumber"})
    (vim.api.nvim_create_autocmd :InsertLeave
                                 {:group g :command "set relativenumber"})
    ;; enable number in telescope preview
    (vim.api.nvim_create_autocmd :User
                                 {:group g
                                  :pattern :TelescopePreviewerLoaded
                                  :command "setlocal number"})
    ;; delete empty space from the end of lines on every save
    (vim.api.nvim_create_autocmd :BufWritePre
                                 {:group g :command "%s/\\s\\+$//e"}))
  (let [g (vim.api.nvim_create_augroup :filetype-mappings {:clear true})]
    (vim.api.nvim_create_autocmd :FileType
                                 {:group g
                                  :pattern "python,json"
                                  :callback (fn []
                                              (set vim.o.shiftwidth 2)
                                              (set vim.o.tabstop 2)
                                              (set vim.o.softtabstop 2))})
    ;; https://superuser.com/questions/741422/vim-move-word-skips-dot
    (vim.api.nvim_create_autocmd :FileType
                                 {:group g
                                  :pattern "fennel,lisp"
                                  :command "setlocal lisp iskeyword-=_ iskeyword-=."})
    (vim.api.nvim_create_autocmd :FileType
                                 {:group g
                                  :pattern "make"
                                  :command "setlocal iskeyword+=-"})

    ;; <cr> enters command mode everywhere except in quickfix
    (vim.api.nvim_create_autocmd :BufEnter
                                 {:group g
                                  :callback (fn []
                                              (if (= :qf vim.bo.filetype)
                                                  (unmap [:n] :<cr>)
                                                  (map [:n] :<cr> ":")))}))

  (let [g (vim.api.nvim_create_augroup :window-switching {:clear true})]
    (vim.api.nvim_create_autocmd [:VimEnter :WinEnter]
                                 {:group g
                                  :callback (fn []
                                              (set vim.o.cursorline true)
                                              (set vim.o.cursorcolumn true))})
    (vim.api.nvim_create_autocmd :WinLeave
                                 {:group g
                                  :callback (fn []
                                              (set vim.o.cursorline true)
                                              (set vim.o.cursorcolumn false))}))
  (let [g (vim.api.nvim_create_augroup :go-format {:clear true})]
    (vim.api.nvim_create_autocmd :BufWritePre
                                 {:group g
                                  :pattern :*.go
                                  :callback (fn []
                                              (set gof (require :go.format))
                                              (gof.goimport))}))
  (let [g (vim.api.nvim_create_augroup :large-files {:clear true})]
    (vim.api.nvim_create_autocmd :BufReadPre
                                 {:group g
                                  :callback (fn [ev]
                                              ;; cannot get number of lines if buffer is not fully read
                                              ;;(when (or (> (vim.api.nvim_buf_line_count bufnr) 5_000))
                                              ;;          (> (vim.fn.getfsize (vim.fn.bufname bufnr)) (* 1024 1024))
                                              (if (<= (vim.fn.getfsize (vim.fn.bufname (. ev :buf)))
                                                      (* 1024 1024))
                                                  (set vim.o.foldmethod :expr)
                                                  (set vim.o.foldmethod :indent)))}))
  ;;(let [g (vim.api.nvim_create_augroup "diagnotics" {:clear true})]
  ;;  (vim.api.nvim_create_autocmd
  ;;    "DiagnosticChanged"
  ;;    {:group g
  ;;     :callback (fn [ev]
  ;;                 (log.debug ev))})))
  (let [g (vim.api.nvim_create_augroup :autosave {:clear true})]
    (vim.api.nvim_create_autocmd :InsertLeave
                                 {:group g
                                  :callback (fn []
                                              (when (and (not vim.bo.readonly)
                                                         (vim.fn.filereadable (vim.fn.expand "%")))
                                                (vim.cmd "silent! update")))})))

(set vim.g.editorconfig false)

(set vim.g.mapleader ";")

(set vim.o.number true)
(set vim.o.relativenumber true)
(set vim.o.ruler true)

(set vim.o.autoread true)
(set vim.o.autowrite true)
(set vim.o.autoindent true)

(set vim.o.scrolloff 15)
(set vim.o.hlsearch true)
(set vim.o.incsearch true)
(set vim.o.ignorecase true)
(set vim.o.smartcase true)
(set vim.o.cmdheight 1)

(let [indent 4]
  (set vim.o.shiftwidth indent)
  (set vim.o.tabstop indent)
  (set vim.o.softtabstop indent)
  (set vim.o.expandtab true))

(set vim.o.splitbelow true)
(set vim.o.splitright true)

(set vim.o.hidden true)
(set vim.o.wrap true)
(set vim.o.swapfile false)

(set vim.o.title true)
(set vim.o.guicursor "n-v-c-sm:block")
(set vim.o.mouse nil)
(set vim.o.encoding :utf-8)
(set vim.o.spell false)
(set vim.o.wildmenu true)
(set vim.o.showmode true)
(set vim.o.showcmd true)

(local interval 300)
(set vim.o.timeout true)
(set vim.o.timeoutlen interval)
(set vim.o.updatetime interval)

(set vim.o.list true)
(set vim.opt.listchars {:tab "▸ " :eol "↵"}) ; :space "⋅"})

;; open all folds by default
(set vim.o.foldenable false)
(set vim.o.foldexpr "nvim_treesitter#foldexpr()")

;; undo dir
(local undodir_path (.. (os.getenv :HOME) :/.nvim/undo-dir/))
(when (= 0 (vim.fn.isdirectory undodir_path))
  (vim.fn.mkdir undodir_path :p))

(set vim.o.undodir undodir_path)
(set vim.o.undofile true)

;(vim.cmd "colorscheme monokai-pro-spectrum")
(match (pcall #(vim.cmd "colorscheme PaperColor"))
  (true _) (vim.notify "Successfully set colorscheme to PaperColor" vim.log.levels.INFO)
  (false err) (vim.notify (.. "Failed to set papercolor theme: " err) vim.log.levels.WARN))
(set vim.o.background :dark)

(vim.cmd "hi VertSplit ctermbg=NONE guibg=NONE guifg=NONE")
