(module core)
;; autocmd

(fn restore-cursor []
  (when (<= (vim.fn.line "'\"") (vim.fn.line "$"))
    (vim.fn.execute "normal! g`\"")))

(when (vim.fn.has :autocmd)
  ;; restore cursor last position in file, silent since for new file would error
  (vim.api.nvim_create_autocmd :BufReadPost {
    :pattern "*"
    :callback restore-cursor
  })

  ;; <cr> enters command mode everywhere except in quickfix
  (let [group (vim.api.nvim_create_augroup "filetype-mappings" {})]
    (vim.api.nvim_create_autocmd
      "BufEnter"
      {:group group
       :callback (fn []
                  (if (= "qf" vim.bo.filetype)
                    (unmap [:n] "<cr>")
                    (map [:n] "<cr>" ":")))}))

  (let [group (vim.api.nvim_create_augroup "window-switching" {})]
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

  ;; switch off relative number in insert mode
  (vim.cmd "autocmd InsertEnter * :set norelativenumber")
  (vim.cmd "autocmd InsertLeave * :set relativenumber")
  ;; delete empty space from the end of lines on every save
  (vim.cmd "autocmd BufWritePre * :%s/\\s\\+$//e")
  (vim.cmd "autocmd InsertLeave * if &readonly == 0 && filereadable(bufname('%')) | silent! update | endif")

  (vim.cmd "autocmd User TelescopePreviewerLoaded setlocal number")
  ;; load all go mods
  (vim.cmd "autocmd BufRead \"$GOPATH/src/*/*.go\" :GoGuruScope ...")
  ;; https://superuser.com/questions/741422/vim-move-word-skips-dot
  (vim.cmd "autocmd FileType fennel :set lisp iskeyword-=_ iskeyword-=."))

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

(local indent 4)
(set vim.o.shiftwidth indent)
(set vim.o.tabstop indent)
(set vim.o.softtabstop indent)
(set vim.o.expandtab true)

(set vim.o.splitbelow true)
(set vim.o.splitright true)

(set vim.o.hidden true)
(set vim.o.wrap true)
(set vim.o.swapfile false)

(set vim.o.title true)
(set vim.o.termguicolors true)
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
(set vim.opt.listchars {:tab "▸ " :space "⋅" :eol "↵"})

(set vim.o.foldenable true)
(set vim.o.foldlevel 99)
(set vim.o.foldmethod :expr)
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

