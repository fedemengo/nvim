(module mapping)

;; open new file at current line in new tab
(fn opentab-at-location []
  (if (= 0 (length (vim.fn.expand "%")))
    (vim.cmd "tabedit") ;; open empty new tab
    (let [line (vim.fn.line ".")
          col (vim.fn.col ".")]
      (vim.cmd "tabedit %")
      (vim.api.nvim_win_set_cursor 0 [line (- col 1)])))) ;; :h nvim_win_set_cursor()

(fn opentab-at-location-and-back []
  (opentab-at-location)
  (vim.cmd "tabprev"))

(fn toggle-theme []
  (if (= "dark" (. vim.o "background"))
    (set vim.o.background "light")
    (set vim.o.background "dark")))

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

;; disable arrows
(map [:n :i :v :x :c] :<up>     :<nop>)
(map [:n :i :v :x :c] :<down>   :<nop>)
(map [:n :i :v :x :c] :<left>   :<nop>)
(map [:n :i :v :x :c] :<right>  :<nop>)

(map [:i :t :v :x :c] :jk :<Esc>)
(map [:i :t :v :x :c] :jk "<C-\\><C-n>")

;; quick movement between splits
(each [_ k (pairs [:h :j :k :l])]
  (map ["n"] (.. "<C-" k ">") (.. "<C-w>" k)))

;; from normal to command mode with enter
(map [:n] :<cr> ":")

;; keep cursor at location after visual yank
(map [:v] :y "myy`y")
(map [:v] :Y "myY`y")

;; keep visual while indenting left/right
(map [:v :s] :< :<gv)
(map [:v :s] :> :>gv)
(map [:n]       :gf          (bindcmd "edit <cfile>")                                        {:desc "Edit file under cursor"})

(map [:n]       :<Esc>       (bindcmd "silent! nohls")                                       {:desc "Clear search highlight"})
(map [:n]       :<C-s>       (bindcmd ["tabnew" "Startify"])                                 {:desc "Launch Startify"})
(map [:n :i :v] :<C-g>       (bindcmd "echo expand('%:p') . ':' . line(\".\")")              {:desc "Print full path of current buffer"})
(map [:n]       :<A-s>       (bindcmd ["set spell!" "set spell?"])                           {:desc "Toggle spell and print status"})
(map [:n]       :<A-t>       toggle-theme                                                    {:desc "Toggle dark/light theme"})
(map [:n]       :<C-b>       opentab-at-location-and-back                                    {:desc "Open buf in new tab"})
(map [:n]       :<C-n>       opentab-at-location                                             {:desc "Open buf in new tab with focus"})

(map [:n]       :<leader>cu  open-web-commit                                                 {:desc "Open commit in browser"})
(map [:n]       :<leader>Cf  (bindcmd "edit $HOME/.config/nvim/")                            {:desc "Open nvim config in buffer"})
(map [:n]       :<leader>cf  (bindcmd "tabedit $HOME/.config/nvim/")                         {:desc "Open nvim config in new tab"})
(map [:n]       :<leader>fp  (bindcmd "silent! let @+=expand(\"%:p\") . ':' . line(\".\")")  {:desc "Copy file path"})

(map [:n]       :<leader>h   (bindcmd "tabmove -1")                                          {:desc "Move tab to the left"})
(map [:n]       :<leader>l   (bindcmd "tabmove +1")                                          {:desc "Move tab to the right"})
(map [:n]       :<leader>s   (bindcmd "split")                                               {:desc "Split window horizontally"})
(map [:n]       :<leader>v   (bindcmd "vsplit")                                              {:desc "Split window vertically"})
(map [:n]       :<leader>q   (bindcmd "qa")                                                  {:desc "Quit all"})
(map [:n]       :<leader>Q   (bindcmd "qa!")                                                 {:desc "Force quit all"})
(map [:n :v]    :<leader>d64 "c<C-r>=system('base64 --decode', @\")<cr><Esc>"                {:desc "Decode selection from base64"})
(map [:n :v]    :<leader>e64 "c<C-r>=system('base64', @\")<cr><Esc>"                         {:desc "Encode selection in base64"})

(map [:n :v]    :<leader>y   "\"+y"                                                          {:desc "Yank to clipboard"})
(map [:n]       :<leader>Y   "\"+Y"                                                          {:desc "Yank line to clipboard"})
(map [:n :v]    :<leader>p   "\"+p"                                                          {:desc "Paste from clipboard after cursor"})
(map [:n]       :<leader>P   "\"+P"                                                          {:desc "Paste from clipboard before cursor"})
(map [:x]       :<leader>p   "\"_dP")

