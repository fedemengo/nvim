(module mapping
  {autoload
   {wkey which-key}})

(local map vim.keymap.set)

(map ["n"] "<leader>Cf" (bindcmd "edit $HOME/.config/nvim/"))
(map ["n"] "<leader>cf" (bindcmd "tabedit $HOME/.config/nvim/"))

(map ["n"] "<leader>nn" (bindcmd "NvimTreeToggle"))

(map ["n" "i" "v"] "<C-g>" (bindcmd "echo expand('%:p') . ':' . line(\".\")"))

;; open new file at current line in new tab
(fn opentab-at-location []
  (if (= 0 (length (vim.fn.expand "%")))
    (vim.cmd "tabedit") ;; open empty new tab
    (let [line (vim.fn.line ".")
          col (vim.fn.col ".")]
      (vim.cmd "tabedit %")
      (vim.api.nvim_win_set_cursor 0 [line (- col 1)])))) ;; :h nvim_win_set_cursor()

(map ["n"] "<C-n>" opentab-at-location)
(map ["n"] "<C-b>" (bindcmd ["tabnew" "Startify"]))

(map ["i"] "jk" "<esc>")
(map ["i"] "jk" "<C-\\><C-n>")

;; yank/paste to/from clipboard - doesnt work in which-key
(map ["n" "v"] "<leader>y" "\"+y")
(map ["n"] "<leader>Y" "\"+Y")
(map ["n" "v"] "<leader>p" "\"+p")
(map ["n"] "<leader>P" "\"+P")
(map ["x"] "<leader>p" "\"_dP")

;; disable arrows
(map ["n" "i" "v" "x" "c"] "<up>" "<nop>")
(map ["n" "i" "v" "x" "c"] "<down>" "<nop>")
(map ["n" "i" "v" "x" "c"] "<left>" "<nop>")
(map ["n" "i" "v" "x" "c"] "<right>" "<nop>")

;; keep cursor at location after visual yank
(map ["v"] "y" "myy`y")
(map ["v"] "Y" "myY`y")

;; edit file under cursor
(map ["n"] "gf" (bindcmd "edit <cfile>"))

;; quick movement between splits
(each [_ k (pairs [:h :j :k :l])]
  (map ["n"] (.. "<C-" k ">") (.. "<C-w>" k)))

(map ["n"] "ß" (bindcmd ["set spell!" "set spell?"])) ;; <A-s>

(map ["n"] "<leader>t" (bindcmd "lua require('FTerm').toggle()"))
(map ["t"] "<leader>t" "<C-\\><C-n><cmd>lua require('FTerm').toggle()<cr>")

;; keep visual while indenting left/right
(map ["v" "s"] "<" "<gv")
(map ["v" "s"] ">" ">gv")

;; from normal to command mode with enter
(map ["n"] "<cr>" ":")

(fn toggle-theme []
  (if (= "dark" (. vim.o "background"))
    (set vim.o.background "light")
    (set vim.o.background "dark")))

(map ["n"] "†" toggle-theme) ;; <A-t>

(fn open-web-commit []
  (let [path (vim.fn.shellescape (vim.fn.expand "%:p:h"))
        file (vim.fn.shellescape (vim.fn.expand "%:t"))
        line (vim.fn.shellescape (vim.fn.line "."))]
    (vim.fn.execute (.. "!open-web-commit" " " path " " file " " line))
    (let [code (. vim.v "shell_error")]
      (when (= 1 code)
        (print (.. path " is not a git repository"))
      (when (= 2 code)
        (print (.. path "/" file ":" line " was never committed")))))))

(map ["n"] "<leader>cu" open-web-commit)

(wkey.register {:<Esc> [(bindcmd "silent! nohls")  "Clear search highlight"]})

(wkey.register
  {
    :c {
      :w [vim.lsp.buf.rename "LSP rename"]
      :a [vim.lsp.buf.code_action "Code actions"]}
    :d64 ["c<C-r>=system('base64 --decode', @\")<cr><esc>" "Decode selection in base64"]
    :e64 ["c<C-r>=system('base64', @\")<cr><esc>" "Encode selection in base64"]
    :f {
      :p [(bindcmd "silent! let @+=expand(\"%:p\") . ':' . line(\".\")") "Copy file path"]
      :q [(bindcmd "qa") "Force quit"]}
    :h [(bindcmd "tabmove -1") "Move tab to the left"]
    :l [(bindcmd "tabmove +1") "Move tab to the right"]
    :s [(bindcmd "split")      "Split window horizontally"]
    :v [(bindcmd "vsplit")     "Split window vertically"]
    :zz [(bindcmd "ZenMode") "Zen mode"]}
  { :prefix "<leader>" })

