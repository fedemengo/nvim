(module :mods.lsp.blink)

(local blink (require :blink.cmp))

(blink.setup
  {:keymap {:<C-q> [:scroll_documentation_up :fallback]
            :<C-w> [:scroll_documentation_down :fallback]
            :<C-p> [:select_prev :fallback]
            :<C-n> [:select_next :fallback]
            :<C-e> [:hide :fallback]
            :<C-y> [:accept :fallback]
            :<S-Tab> [:show :fallback]}
   :completion {:menu {:border :rounded}
                :documentation {:auto_show true
                                :window {:border :rounded}}
                :ghost_text {:enabled true}}
   :sources {:default [:lsp :path :buffer :copilot]
             :providers {:copilot {:name :Copilot
                                   :module :blink-cmp-copilot
                                   :score_offset 100
                                   :async true}}}
   :cmdline {:keymap {:preset :cmdline}
             :sources (fn []
                        (let [t (vim.fn.getcmdtype)]
                          (if (or (= t "/") (= t "?"))
                              [:buffer]
                              (= t ":")
                              [:cmdline :path]
                              [])))
             :completion {:menu {:auto_show true}}}})
