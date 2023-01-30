(module mapping
  {autoload {which-key which-key}}
)

(var map vim.keymap.set)

(map ["n"] "<leader>fq" "<cmd>qa<cr>")
(map ["n" "i" "v"] "<leader>Cf" "<cmd>edit $HOME/.config/nvim/<cr>")
(map ["n" "i" "v"] "<leader>cf" "<cmd>tabedit $HOME/.config/nvim/<cr>")

(map ["n" "i" "v"] "<C-g>" "<cmd>echo expand('%:p') . ':' . line(\".\")<cr>")

(map ["n"] "<C-b>" "<cmd>tabnew<cr><cmd>Startify<cr>")
(map ["n"] "<C-n>" "mt<cmd>tabedit %<cr>`t")

;; open new file at current line in new tab
(map ["n"] "<leader>h" "<cmd>tabmove -1<cr>")
(map ["n"] "<leader>l" "<cmd>tabmove +1<cr>")

(map ["n"] "¡" "1gt")
(map ["n"] "™" "2gt")
(map ["n"] "£" "3gt")
(map ["n"] "¢" "4gt")
(map ["n"] "∞" "5gt")
(map ["n"] "§" "6gt")
(map ["n"] "¶" "7gt")
(map ["n"] "•" "8gt")
(map ["n"] "ª" "9gt")

(map ["n"] "<leader>v" "<cmd>vsplit<cr>")
(map ["n"] "<leader>h" "<cmd>split<cr>")

(map ["i"] "jk" "<esc")
(map ["i"] "jk" "<C-\\><C-n>")

;; yank/past to clipboard
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

(map ["v"] "y" "myy`y")
(map ["v"] "Y" "myY`y")

(map ["v"] "<leader>e64" "c<C-r>=system('base64', @\")<cr><esc>")
(map ["v"] "<leader>d64" "c<C-r>=system('base64 --decode', @\")<cr><esc>")

(map ["n" "i" "v"] "gf" "<cmd>edit <cfile><cr>")

(map ["n"] "<C-h>" "<C-w>h")
(map ["n"] "<C-j>" "<C-w>j")
(map ["n"] "<C-k>" "<C-w>k")
(map ["n"] "<C-l>" "<C-w>l")

(map ["n"] "ß" "<cmd>set spell!<cr>")

(fn toggle-theme []
  (if (= "dark" (. vim.o "background"))
    (set vim.o.background "light")
    (set vim.o.background "dark")
  )
)
(map ["n"] "†" toggle-theme)

(fn open-web-commit []
  (let [
      path (vim.fn.shellescape (vim.fn.expand "%:p:h"))
      file (vim.fn.shellescape (vim.fn.expand "%:t"))
      line (vim.fn.shellescape (vim.fn.line "."))
    ]
    (vim.fn.execute (.. "!open-web-commit" " " path " " file " " line))
    (let [code (. vim.v "shell_error")]
      (if (= 1 code)
        (print (.. path " is not a git repository"))
        (if (= 2 code)
          (print (.. path "/" file ":" line " was never committed"))
          ;; ok otherwise
        )
      )
    )
  )
)
(map ["n"] "<leader>cu" open-web-commit)

(which-key.register
  {
    :f {
      :name "find"
      :f ["<cmd>lua require('telescope.builtin').find_files()<cr>" "Find files"]
      :g ["<cmd>lua require('telescope.builtin').live_grep()<cr>" "Grep string"]
      :s ["<cmd>lua require('telescope.builtin').grep_string()<cr" "Find string"]
      :z ["<cmd>lua require('telescope.builtin').grep_string({shorten_path = true, only_sort_text = true, search = ''})<cr>" "Fuzzy grep sring"]
      :b ["<cmd>lua require('telescope.builtin').buffers()<cr>" "Find buffers"]
      :c ["<cmd>lua require('telescope.builtin').command_history()<cr>" "Commands history"]
      :r ["<cmd>lua require('telescope.builtin').lsp_references()<cr>" "LSP references"]
      :i ["<cmd>lua require('telescope.builtin').lsp_implementations()<cr>" "LSP implementations"]
      :c ["<cmd>lua require('telescope.builtin').git_commits()<cr>" "Commit history"]
      :s ["<cmd>lua require('telescope.builtin').git_status()<cr>" "Git status"]
      :S ["<cmd>lua require('telescope.builtin').git_stash()<cr>" "Git stashes"]
      :e ["<cmd>lua require('telescope.builtin').diagnostics()<cr>" "Diagnostics"]
    }
    :<Esc> ["<cmd>silent! nohls<cr>"  "Clear search highlight"]
  }
)

(which-key.register
  {
    :f {
      :p ["<cmd>silent! let @+=expand(\"%:p\") . ':' . line(\".\")<cr>" "Copy file path"]
    }
    :c {
      :w ["<cmd>lua vim.lsp.buf.rename()<cr>" "LSP rename"]
      :a ["<cmd>lua vim.lsp.buf.code_action()<cr>" "Code actions"]
      :a ["<cmd>lua vim.lsp.buf.range_code_action()<cr>" "Code actions" {:mode ["v" "x"]}]
    }
    :p {
      :name "plugins"
      :i ["<cmd>PackerInstall<cr>" "Install plugins"]
      :u ["<cmd>PackerUpdate<cr>"  "Update plugins"]
      :c ["<cmd>PackerCompile<cr>" "Compile packer file"]
      :C ["<cmd>PackerClean<cr>"   "Clean plugins"]
    }
    :zz ["<cmd>ZenMode<cr>" "Zen mode"]
  }
  {
    :prefix "<leader>"
  }
)

