(module core)
;; autocmd

(when (vim.fn.has :autocmd)
  (let [group (vim.api.nvim_create_augroup "misc" {:clear true})]
    ;; restore cursor last position in filesilent since for new file would error
    (vim.api.nvim_create_autocmd
      :BufReadPost
      {:group group
       :pattern "*"
       :callback (fn restore-cursor []
                  (when (<= (vim.fn.line "'\"") (vim.fn.line "$"))
                    (vim.fn.execute "normal! g`\"")))})

    ;; switch off relative number in insert mode
    (vim.api.nvim_create_autocmd
      "InsertEnter"
      {:group group
       :command "set norelativenumber"})
    (vim.api.nvim_create_autocmd
      "InsertLeave"
      {:group group
       :command "set relativenumber"})

    ;; enable number in telescope preview
    (vim.api.nvim_create_autocmd
      "User TelescopePreviewerLoaded"
      {:group group
       :command "setlocal number"})

    ;; delete empty space from the end of lines on every save
    (vim.api.nvim_create_autocmd
      "BufWritePre"
      {:group group
       :command "%s/\\s\\+$//e"}))

  (let [group (vim.api.nvim_create_augroup "filetype-mappings" {:clear true})]
    (vim.api.nvim_create_autocmd
      "FileType"
      {:group group
       :pattern "python"
       :callback (fn []
                  (set vim.o.shiftwidth 2)
                  (set vim.o.tabstop 2)
                  (set vim.o.softtabstop 2))})

    ;; https://superuser.com/questions/741422/vim-move-word-skips-dot
    (vim.api.nvim_create_autocmd
      "FileType"
      {:group group
       :pattern "fennel,lisp"
       :command "setlocal lisp iskeyword-=_ iskeyword-=."})

    ;; <cr> enters command mode everywhere except in quickfix
    (vim.api.nvim_create_autocmd
      "BufEnter"
      {:group group
       :callback (fn []
                  (if (= "qf" vim.bo.filetype)
                    (unmap [:n] "<cr>")
                    (map [:n] "<cr>" ":")))}))

  (let [group (vim.api.nvim_create_augroup "window-switching" {:clear true})]
    (vim.api.nvim_create_autocmd
      ["VimEnter" "WinEnter"]
      {:group group
       :callback (fn []
                  (set vim.o.cursorline true)
                  (set vim.o.cursorcolumn true))})
    (vim.api.nvim_create_autocmd
        "WinLeave"
        {:group group
         :callback (fn []
                    (set vim.o.cursorline true)
                    (set vim.o.cursorcolumn false))}))

  (let [group (vim.api.nvim_create_augroup "go-format" {:clear true})]
    (vim.api.nvim_create_autocmd
      "BufWritePre"
      {:group group
       :pattern "*.go"
       :callback (fn []
                   (set gof (require "go.format"))
                   (gof.goimport))}))

  (let [group (vim.api.nvim_create_augroup "large-files" {:clear true})]
    (vim.api.nvim_create_autocmd
      "BufReadPre"
      {:group group
       :callback (fn [ev]
                    ;; cannot get number of lines if buffer is not fully read
                    ;;(when (or (> (vim.api.nvim_buf_line_count bufnr) 5_000))
                    ;;          (> (vim.fn.getfsize (vim.fn.bufname bufnr)) (* 1024 1024))
                    (if (<= (vim.fn.getfsize (vim.fn.bufname (. ev :buf))) (* 1024 1024))
                      (set vim.o.foldmethod :expr)
                      (set vim.o.foldmethod :indent)))}))

  ;;(let [group (vim.api.nvim_create_augroup "diagnotics" {:clear true})]
  ;;  (vim.api.nvim_create_autocmd
  ;;    "DiagnosticChanged"
  ;;    {:group group
  ;;     :callback (fn [ev]
  ;;                 (log.debug ev))})))


  (let [group (vim.api.nvim_create_augroup "autosave" {:clear true})]
    (vim.api.nvim_create_autocmd
      "InsertLeave"
      {:group group
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
(set vim.o.guicursor :n-v-c-sm:block)
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

; open all folds by default
(set vim.o.foldenable false)
(set vim.o.foldexpr "nvim_treesitter#foldexpr()")

;; undo dir
(local undodir_path (.. (os.getenv :HOME) :/.nvim/undo-dir/))
(when (= 0 (vim.fn.isdirectory undodir_path))
  (vim.fn.mkdir undodir_path :p))

(set vim.o.undodir undodir_path)
(set vim.o.undofile true)

;;(vim.cmd "colorscheme github_dimmed")
(vim.cmd "colorscheme PaperColor")
(set vim.o.background :dark)

(vim.cmd "hi VertSplit ctermbg=NONE guibg=NONE guifg=NONE")

