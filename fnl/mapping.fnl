(module :mapping)

;; open new file at current line in new tab

(fn opentab-at-location []
  (if (= 0 (length (vim.fn.expand "%")))
      (vim.cmd :tabedit)
      ;; open empty new tab if no file is open
      (let [line (vim.fn.line ".")
            col (vim.fn.col ".")]
        (vim.cmd "tabedit %")
        ;; open current file in new tab
        (vim.api.nvim_win_set_cursor 0 [line (- col 1)]))))

;; move to location :h nvim_win_set_cursor()

(fn opentab-at-location-and-back []
  (opentab-at-location)
  (vim.cmd :tabprev))

;; for themes respecting vim.o.background

(fn toggle-theme []
  (if (= :dark (. vim.o :background))
      (set vim.o.background :light)
      (set vim.o.background :dark)))

(fn open-web-commit []
  (let [path (vim.fn.expand "%:p:h")
        file (vim.fn.expand "%:t")
        line (vim.fn.line ".")
        safe_path (vim.fn.shellescape path)
        safe_file (vim.fn.shellescape file)]
    (vim.fn.execute (.. "!open-web-commit " safe_path " " safe_file " " line))
    (match vim.v.shell_error
      1 (print (.. path " is not a git repository"))
      2 (print (.. path "/" file ":" line " was never committed")))))

(fn copy-file-path []
  (let [fp (vim.fn.expand "%:p")
        line (vim.fn.line ".")
        relfp (fp:gsub (os.getenv :HOME) :$HOME)]
    (vim.cmd (.. "silent! let @+='" relfp ":" line "'"))))

(fn eval-expression []
  (let [(_ sr sc _) (unpack (vim.fn.getpos :v))
        (_ er ec _) (unpack (vim.fn.getpos "."))]
    (if (not= sr er)
        (print "cannot eval multiline expression")
        (let [line (car (vim.fn.getline sr er))
              text (string.sub line sc ec)
              startcol (-- sc)
              endcol (min ec (length line))]
          (var res (safe-eval text))
          (var newline
               (.. (string.sub line 0 startcol) text "=" res
                   (string.sub line (++ endcol))))
          (vim.api.nvim_buf_set_text 0 (-- sr) 0 (-- er) (length line)
                                     [newline])))))

(fn toggle-wrap []
  (let [has-wrap (. vim.wo :wrap)]
    (if has-wrap
      (vim.cmd "windo set nowrap")
      (vim.cmd "windo set wrap"))))

(map [:v] :<leader><space> eval-expression {:desc "Evaluate expression"})

;; search with s instead of f

(map [:n] :s :f)
(map [:n] :S :F)

;; disable arrows

(map [:n :i :v :x :c] :<up> :<nop>)
(map [:n :i :v :x :c] :<down> :<nop>)
(map [:n :i :v :x :c] :<left> :<nop>)
(map [:n :i :v :x :c] :<right> :<nop>)

;; jk is the new esc

(map [:i :t :v :x :c] :jk :<Esc>)
(map [:i :t :v :x :c] :jk "<C-\\><C-n>")

;; move in cmd mode

(map [:c] :<C-b> :<S-Left>)
(map [:c] :<C-f> :<S-Right>)

;; quick movement between splits

(each [_ k (pairs [:h :j :k :l])]
  (map [:n] (.. :<C- k ">") (.. :<C-w> k)))

;; keep cursor at location after visual yank

(map [:v] :y "myy`y")
(map [:v] :Y "myY`y")

(map [:n] :tv (bindcmd [:vsplit :term]) {:desc "Open term in vertical split"})
(map [:n] :ts (bindcmd [:split :term]) {:desc "Open term in horizontal split"})
(map [:n :t] :<leader>ex (bindcmd :exit) {:desc "Close current buffer"})

;; keep visual mode while indenting left/right

(map [:v :s] "<" :<gv)
(map [:v :s] ">" :>gv)
(map [:n] :gf (bindcmd "edit <cfile>") {:desc "Edit file under cursor"})

;; hide search highlight

(map [:n] :<Esc> (bindcmd "silent! nohls") {:desc "Clear search highlight"})
(map [:n] :<C-s> (bindcmd [:tabnew :Startify]) {:desc "Launch Startify"})
(map [:n :i :v] :<C-g> (bindcmd "echo expand('%:p') . ':' . line(\".\")")
     {:desc "Print full path of current buffer"})

(map [:n] :<A-s> (bindcmd ["set spell!" "set spell?"])
     {:desc "Toggle spell and print status"})

(map [:n] :<A-t> toggle-theme {:desc "Toggle dark/light theme"})
(map [:n] :<C-b> opentab-at-location-and-back {:desc "Open buf in new tab"})
(map [:n] :<C-n> opentab-at-location {:desc "Open buf in new tab with focus"})

(map [:n] :<leader>cu open-web-commit {:desc "Open commit in browser"})
(map [:n] :<leader>Cf (bindcmd "edit $HOME/.config/nvim/")
     {:desc "Open nvim config in buffer"})

(map [:n] :<leader>cf (bindcmd "tabedit $HOME/.config/nvim/")
     {:desc "Open nvim config in new tab"})

(map [:n] :<leader>fp copy-file-path {:desc "Copy file path"})

(map [:n] :<leader>h (bindcmd "tabmove -1") {:desc "Move tab to the left"})
(map [:n] :<leader>l (bindcmd "tabmove +1") {:desc "Move tab to the right"})

(map [:n] :<leader>s (bindcmd :split) {:desc "Split window horizontally"})
(map [:n] :<leader>v (bindcmd :vsplit) {:desc "Split window vertically"})
(map [:n] :sd        (bindcmd "vertical resize -15") {:desc "Decrease split width"})
(map [:n] :si        (bindcmd "vertical resize +15") {:desc "Increase split width"})
(map [:n] :<leader>w toggle-wrap {:desc "Toggle wrap"})

(map [:n] :<leader>q (bindcmd :qa) {:desc "Quit all"})
(map [:n] :<leader>Q (bindcmd :qa!) {:desc "Force quit all"})
(map [:n :v] :<leader>d64 "c<C-r>=system('base64 --decode', @\")<cr><Esc>"
     {:desc "Decode selection from base64"})

(map [:n :v] :<leader>e64 "c<C-r>=system('base64', @\")<cr><Esc>"
     {:desc "Encode selection in base64"})

(map [:n :v] :<leader>y "\"+y" {:desc "Yank to clipboard"})
(map [:n] :<leader>Y "\"+Y" {:desc "Yank line to clipboard"})
(map [:n :v] :<leader>p "\"+p" {:desc "Paste from clipboard after cursor"})
(map [:n] :<leader>P "\"+P" {:desc "Paste from clipboard before cursor"})
(map [:x] :<leader>p "\"_dP")

(map [:n] :<S-Tab> :za {:desc "Toggle fold under cursor"})

;; https://github.com/folke/which-key.nvim#%EF%B8%8F-configuration
;; this is discouraged, but hey https://xkcd.com/1172

(map [:n] :f (bindcmd "WhichKey f"))
(map [:n] :t (bindcmd "WhichKey t"))
