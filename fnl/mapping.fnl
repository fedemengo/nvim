(module mapping
  {autoload {which-key which-key}}
)

(local map vim.keymap.set)

(map ["n"] "<leader>Cf" "<cmd>edit $HOME/.config/nvim/<cr>")
(map ["n"] "<leader>cf" "<cmd>tabedit $HOME/.config/nvim/<cr>")

(map ["n"] "<leader>nn" "<cmd>NvimTreeToggle<cr>")

(map ["n" "i" "v"] "<C-g>" "<cmd>echo expand('%:p') . ':' . line(\".\")<cr>")

;; open new file at current line in new tab
(fn open-and-move []
  (let [line (vim.fn.line ".")
        col (vim.fn.col ".")]
    (vim.cmd "tabedit %")
    (vim.api.nvim_win_set_cursor 0 [line (- col 1)]) ;; :h nvim_win_set_cursor()
  )
)
(fn opentab-at-location []
  (if (= 0 (length (vim.fn.expand "%")))
    (vim.cmd "tabedit") ;; open empty new tab
    (open-and-move)     ;; open buf in new tab and move cursor
  )
)
(map ["n"] "<C-n>" opentab-at-location)
(map ["n"] "<C-b>" "<cmd>tabnew<cr><cmd>Startify<cr>")

(map ["n"] "¡" "<cmd> lua require('bufferline').go_to_buffer(1, true)<cr>")
(map ["n"] "™" "<cmd> lua require('bufferline').go_to_buffer(2, true)<cr>")
(map ["n"] "£" "<cmd> lua require('bufferline').go_to_buffer(3, true)<cr>")
(map ["n"] "¢" "<cmd> lua require('bufferline').go_to_buffer(4, true)<cr>")
(map ["n"] "∞" "<cmd> lua require('bufferline').go_to_buffer(5, true)<cr>")
(map ["n"] "§" "<cmd> lua require('bufferline').go_to_buffer(6, true)<cr>")
(map ["n"] "¶" "<cmd> lua require('bufferline').go_to_buffer(7, true)<cr>")
(map ["n"] "•" "<cmd> lua require('bufferline').go_to_buffer(8, true)<cr>")
(map ["n"] "ª" "<cmd> lua require('bufferline').go_to_buffer(9, true)<cr>")

(map ["i"] "jk" "<esc")
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
(map ["n"] "gf" "<cmd>edit <cfile><cr>")

;; quick movement between splits
(map ["n"] "<C-h>" "<C-w>h")
(map ["n"] "<C-j>" "<C-w>j")
(map ["n"] "<C-k>" "<C-w>k")
(map ["n"] "<C-l>" "<C-w>l")

(map ["n"] "ß" "<cmd>set spell!<cr><cmd>set spell?<cr>")

(map ["n"] "<leader>t" "<cmd>lua require('FTerm').toggle()<cr>")
(map ["t"] "<leader>t" "<C-\\><C-n><cmd>lua require('FTerm').toggle()<cr>")

;; keep visual while indenting left/right
(map ["v" "s"] "<" "<gv")
(map ["v" "s"] ">" ">gv")

;; from normal to command mode with enter
(map ["n"] "<cr>" ":")

(fn toggle-theme []
  (if (= "dark" (. vim.o "background"))
    (set vim.o.background "light")
    (set vim.o.background "dark")
  )
)
(map ["n"] "†" toggle-theme)

(fn open-web-commit []
  (let [path (vim.fn.shellescape (vim.fn.expand "%:p:h"))
        file (vim.fn.shellescape (vim.fn.expand "%:t"))
        line (vim.fn.shellescape (vim.fn.line "."))]
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
      :s ["<cmd>lua require('telescope.builtin').grep_string()<cr>" "Find string"]
      :z ["<cmd>lua require('telescope.builtin').grep_string({shorten_path = true, only_sort_text = true, search = ''})<cr>" "Fuzzy grep sring"]
      :b ["<cmd>lua require('telescope.builtin').buffers()<cr>" "Find buffers"]
      :c ["<cmd>lua require('telescope.builtin').command_history()<cr>" "Commands history"]
      :e ["<cmd>lua require('telescope.builtin').diagnostics()<cr>" "Diagnostics"]
    }
    :g {
      :r ["<cmd>lua require('telescope.builtin').lsp_references()<cr>" "LSP references"]
      :i ["<cmd>lua require('telescope.builtin').lsp_implementations()<cr>" "LSP implementations"]
      :c ["<cmd>lua require('telescope.builtin').git_commits()<cr>" "Commit history"]
      :s ["<cmd>lua require('telescope.builtin').git_status()<cr>" "Git status"]
      :S ["<cmd>lua require('telescope.builtin').git_stash()<cr>" "Git stashes"]
    }
    :<Esc> ["<cmd>silent! nohls<cr>"  "Clear search highlight"]
  }
)

(which-key.register
  {
    :b ["<cmd>Git toggle_current_line_blame<cr>" "Git blame"]
    :c {
      :w ["<cmd>lua vim.lsp.buf.rename()<cr>" "LSP rename"]
      :a ["<cmd>lua vim.lsp.buf.code_action()<cr>" "Code actions"]
    }
    :d64 ["c<C-r>=system('base64 --decode', @\")<cr><esc>" "Decode selection in base64"]
    :e64 ["c<C-r>=system('base64', @\")<cr><esc>" "Encode selection in base64"]
    :f {
      :p ["<cmd>silent! let @+=expand(\"%:p\") . ':' . line(\".\")<cr>" "Copy file path"]
      :q ["<cmd>qa<cr>" "Force quit"]
    }
    :h ["<cmd>tabmove -1<cr>" "Move tab to the left"]
    :l ["<cmd>tabmove +1<cr>" "Move tab to the right"]
    :s ["<cmd>split<cr>" "Split window horizontally"]
    :v ["<cmd>vsplit<cr>" "Split window vertically"]
    :zz ["<cmd>ZenMode<cr>" "Zen mode"]
  }
  { :prefix "<leader>" }
)

(which-key.register
  {
    :p {
      :name "plugins"
      :i ["<cmd>PackerInstall<cr>" "Install plugins"]
      :u ["<cmd>PackerUpdate<cr>"  "Update plugins"]
      :c ["<cmd>PackerCompile<cr>" "Compile packer file"]
      :C ["<cmd>PackerClean<cr>"   "Clean plugins"]
    }
  }
  { :prefix "<space>" }
)

