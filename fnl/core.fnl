(module core)

;; autocmd
(when (= 1 (vim.fn.has "autocmd"))
  ;; restore cursor last position in file, silent since for new file would error
  (vim.cmd "autocmd BufWinLeave * if expand('%:p') !='' | silent! mkview | endif")
  (vim.cmd "autocmd BufWinEnter * silent! loadview")

  ;; switch off relative number in insert mode
  (vim.cmd "autocmd InsertEnter * :set norelativenumber")
  (vim.cmd "autocmd InsertLeave * :set relativenumber")

  ;; delete empty space from the end of lines on every save
  (vim.cmd "autocmd BufWritePre * :%s/\\s\\+$//e")
  (vim.cmd "autocmd InsertLeave * if &readonly == 0 && filereadable(bufname('%')) | silent! update | endif")
)

;; leader key
(set vim.g.mapleader ";")

;; general settings
(set vim.o.number true)
(set vim.o.relativenumber true)
(set vim.o.ruler true)

(set vim.o.autoread true)
(set vim.o.autowrite true)
(set vim.o.autoindent true)

(set vim.o.cursorline true)
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
(set vim.o.mouse nil)
(set vim.o.encoding "utf-8")
(set vim.o.spell false)
(set vim.o.wildmenu true)
(set vim.o.showmode true)
(set vim.o.showcmd true)

(set vim.o.list false)
;(set vim.o.listchars {:tab "▸ " :space "⋅" :eol "↵"}) ;; see https://github.com/neovim/neovim/issues/15201#issuecomment-1407728303

;; undo dir
(local undodir_path (.. (?. (vim.fn.environ) :HOME) "/.nvim/undo-dir/"))
(if (= 0 (vim.fn.isdirectory undodir_path))
  (vim.fn.mkdir undodir_path "p")
  ;; directory exists
)
(set vim.o.undodir undodir_path)
(set vim.o.undofile true)

(set vim.o.background "dark")

(vim.cmd "colorscheme PaperColor")
(vim.cmd "hi VertSplit guibg=bg guifg=fg")
