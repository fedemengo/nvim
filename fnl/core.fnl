(module core)
(import-macros {
  :opt-remove optremove
  :opt-set optset
  :opt-append optappend}
  :zest.macros )

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

  (vim.cmd "autocmd BufRead \"$GOPATH/src/*/*.go\" :GoGuruScope ..."))

;; leader key
(set vim.g.mapleader ";")

;; general settings
(set vim.o.number true)
(set vim.o.relativenumber true)
(set vim.o.ruler true)

(set vim.o.autoread true)
(set vim.o.autowrite true)
(set vim.o.autoindent true)

(set vim.o.cursorcolumn true)
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

;; https://superuser.com/questions/741422/vim-move-word-skips-dot
;;(optremove iskeyword ["."])
;;(vim.o.iskeyword:remove ".")

(set vim.o.list true)
(optappend listchars "tab:▸ ")
(optappend listchars "space:⋅")
(optappend listchars "eol:↵")

;; undo dir
(local undodir_path (.. (os.getenv "HOME") "/.nvim/undo-dir/"))
(when (= 0 (vim.fn.isdirectory undodir_path))
  (vim.fn.mkdir undodir_path "p"))

(set vim.o.undodir undodir_path)
(set vim.o.undofile true)

(vim.cmd "hi VertSplit ctermbg=NONE guibg=NONE guifg=NONE")
(vim.cmd "colorscheme PaperColor")
(set vim.o.background "dark")

