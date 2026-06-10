(module mods.ui.alpha)

(local alpha (require :alpha))
(local startify (require :alpha.themes.startify))

;; ensure Startify* groups exist with sensible fallbacks; colorschemes like
;; PaperColor override these with their own definitions
(each [group fallback (pairs {:StartifyHeader  :Comment
                               :StartifySection :Special
                               :StartifyFile    :Directory
                               :StartifyNumber  :Constant
                               :StartifyBracket :Operator
                               :StartifyPath    :Comment})]
  (vim.api.nvim_set_hl 0 group {:default true :link fallback}))

;; patch button: use StartifyBracket/StartifyNumber for [key] shortcut
(local orig-button startify.button)
(set startify.button
     (fn [sc txt keybind keybind-opts]
       (let [btn (orig-button sc txt keybind keybind-opts)]
         (set btn.opts.hl_shortcut
              [[:StartifyBracket 0 1]
               [:StartifyNumber 1 (+ (length sc) 1)]
               [:StartifyBracket (+ (length sc) 1) (+ (length sc) 2)]])
         btn)))

;; patch file_button: use StartifyPath for directory prefix (was Comment)
(local orig-file-button startify.file_button)
(set startify.file_button
     (fn [fn* sc short-fn autocd]
       (let [btn (orig-file-button fn* sc short-fn autocd)]
         (when btn.opts.hl
           (set btn.opts.hl
                (icollect [_ h (ipairs btn.opts.hl)]
                  (if (= (. h 1) :Comment)
                      [:StartifyPath (. h 2) (. h 3)]
                      h))))
         btn)))

;; patch MRU section headers (hardcoded SpecialComment in the theme)
(let [t (. startify.section.mru.val 2)]
  (when t (set t.opts.hl :StartifySection)))

(let [orig-cwd-val startify.section.mru_cwd.val]
  (set startify.section.mru_cwd.val
       (fn []
         (let [result (orig-cwd-val)
               t      (. result 2)]
           (when (and t t.opts)
             (set t.opts.hl :StartifySection))
           result))))

;; header: fortune | owlsay, centered as a block (all lines padded equally)
(local has-fortune (= 1 (vim.fn.executable :fortune)))
(local has-owlsay  (= 1 (vim.fn.executable :owlsay)))
(local has-cowsay  (= 1 (vim.fn.executable :cowsay)))

;; capture fortune once at startup; crop + center at render time when
;; window height is actually known
(local raw-header
  (when has-fortune
    (let [pipe (if has-owlsay "| owlsay" (if has-cowsay "| cowsay" ""))
          cmd  (.. "fortune -s computers linux kernelnewbies knghtbrd science " pipe)
          out (vim.fn.systemlist cmd)]
      (when (> (length out) 0) out))))

(when raw-header
  (set startify.section.header
       {:type :group
        :val  (fn []
                (let [win-h (vim.api.nvim_win_get_height 0)
                      max-h (math.max 10 (- win-h 12))
                      out   (if (> (length raw-header) max-h)
                              (icollect [i l (ipairs raw-header)] (when (<= i max-h) l))
                              raw-header)
                      cols  (if (> vim.o.columns 0) vim.o.columns 80)
                      max-w (accumulate [m 0 _ l (ipairs out)] (math.max m (length l)))
                      pad   (string.rep " " (math.max 0 (math.floor (/ (- cols max-w) 2))))]
                  [{:type :text
                    :val  (icollect [_ l (ipairs out)] (.. pad l))
                    :opts {:hl :StartifyHeader :shrink_margin false}}]))}))

;; action buttons
(set startify.section.top_buttons.val
     [{:type :text :val ["Commands"] :opts {:hl :StartifySection :shrink_margin false}}
      {:type :padding :val 1}
      (startify.button "e" "  New file"  "<cmd>enew<cr>")
      (startify.button "h" "  Health"    "<cmd>checkhealth<cr>")])

(set startify.section.bottom_buttons.val
     [(startify.button "q" "  Quit"      "<cmd>qa<cr>")])

;; bookmarks from ~/.nvim-bookmarks
(local bookmarks
  (vim.fn.systemlist "cut -sd' ' -f 2- ~/.nvim-bookmarks 2>/dev/null"))

(local bookmark-buttons
  (icollect [i path (ipairs bookmarks)]
    (startify.button (tostring i)
                     (.. "  " (vim.fn.fnamemodify path ":~"))
                     (.. "<cmd>e " (vim.fn.fnameescape path) "<cr>"))))

;; sessions section — lists saved persistence.nvim sessions (one per cwd)
(fn sessions-section []
  {:type :group
   :val (fn []
          (let [dir (.. (vim.fn.stdpath :state) :/sessions/)
                files (vim.fn.glob (.. dir "*.vim") false true)]
            (if (> (length files) 0)
                (let [buttons (icollect [i f (ipairs files)]
                                (when (<= i 9)
                                  (let [raw     (vim.fn.fnamemodify f ":t:r")
                                        decoded (raw:gsub "%%" "/")
                                        display (vim.fn.fnamemodify decoded ":~")]
                                    (startify.button (.. "s" (tostring i))
                                                     (.. "  " display)
                                                     (.. "<cmd>source " (vim.fn.fnameescape f) "<cr>")))))]
                  [{:type :padding :val 1}
                   {:type :text :val ["Sessions"] :opts {:hl :StartifySection :shrink_margin false}}
                   {:type :padding :val 1}
                   {:type :group :val buttons}])
                [])))})

;; git section factory — function val so DirChanged refreshes it
(fn git-section [title cmd key-prefix]
  {:type :group
   :val (fn []
          (let [files (vim.fn.systemlist cmd)]
            (if (> (length files) 0)
                [{:type :padding :val 1}
                 {:type :text :val [title] :opts {:hl :StartifySection :shrink_margin false}}
                 {:type :padding :val 1}
                 {:type :group
                  :val (icollect [i f (ipairs files)]
                         (startify.file_button f (.. key-prefix (tostring i))
                                               (vim.fn.fnamemodify f ":.")))}]
                [])))})

(local layout
  [{:type :padding :val 1}
   startify.section.header
   {:type :padding :val 2}
   startify.section.top_buttons])

(when (> (length bookmark-buttons) 0)
  (table.insert layout
    {:type :group
     :val [{:type :padding :val 1}
           {:type :text :val ["Bookmarks"] :opts {:hl :StartifySection :shrink_margin false}}
           {:type :padding :val 1}
           {:type :group :val bookmark-buttons}]}))

;; sessions
(table.insert layout (sessions-section))

;; MRU sections
(table.insert layout
  {:type :group
   :val (fn []
          (let [result []]
            (each [_ name (ipairs startify.mru_sections)]
              (when (. startify.section name)
                (table.insert result (. startify.section name))))
            result))})

;; git modified + untracked (only appear when inside a git repo with changes)
(table.insert layout (git-section "Git modified"  "git ls-files -m 2>/dev/null"                    "m"))
(table.insert layout (git-section "Git untracked" "git ls-files -o --exclude-standard 2>/dev/null" "u"))

(table.insert layout {:type :padding :val 1})
(table.insert layout startify.section.bottom_buttons)
(table.insert layout startify.section.footer)

(alpha.setup
  {:layout layout
   :opts {:margin 3
          :redraw_on_resize false
          :setup (fn []
                   ;; after alpha renders, scroll view back to line 1 without
                   ;; moving the cursor — prevents Vim centering the first button
                   ;; and hiding the header on small screens
                   (vim.api.nvim_create_autocmd :User
                     {:pattern :AlphaReady
                      :callback (fn []
                                  (vim.schedule
                                    (fn [] (vim.cmd "normal! zb"))))})
                   (vim.api.nvim_create_autocmd :DirChanged
                     {:pattern :*
                      :group :alpha_temp
                      :callback (fn []
                                  ((. (require :alpha) :redraw))
                                  (vim.cmd :AlphaRemap))}))}})
