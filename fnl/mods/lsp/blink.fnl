(module :mods.lsp.blink)

(local blink (require :blink.cmp))

(fn set-kind-hl []
  (each [_ [kind target]
         (ipairs [[:Text :String]
                  [:Method :Statement]
                  [:Function :Statement]
                  [:Constructor :Statement]
                  [:Field :Identifier]
                  [:Variable :Identifier]
                  [:Property :Identifier]
                  [:Class :Type]
                  [:Interface :Type]
                  [:Struct :Type]
                  [:Module :Include]
                  [:Unit :Number]
                  [:Value :Number]
                  [:Enum :Type]
                  [:EnumMember :Constant]
                  [:Keyword :Keyword]
                  [:Constant :Constant]
                  [:Snippet :Boolean]
                  [:Color :Directory]
                  [:File :Directory]
                  [:Reference :Directory]
                  [:Folder :Directory]
                  [:Event :Directory]
                  [:Operator :Operator]
                  [:TypeParameter :Type]])]
    (vim.api.nvim_set_hl 0 (.. :BlinkCmpKind kind) {:link target})))

(blink.setup
  {:keymap {:<C-q> [:scroll_documentation_up :fallback]
            :<C-w> [:scroll_documentation_down :fallback]
            :<C-p> [:select_prev :fallback]
            :<C-n> [:select_next :fallback]
            :<C-e> [:hide :fallback]
            :<C-y> [:accept :fallback]
            :<S-Tab> [:show :fallback]}
   :appearance {:nerd_font_variant :mono}
   :completion {:menu {:min_width 30
                       :max_height 15
                       :winblend 5
                       :draw {:columns [[:kind_icon]
                                        (doto [:label :label_description] (tset :gap 1))
                                        [:source_name]]
                              :treesitter [:lsp]}}
                :documentation {:auto_show true
                                :window {:border :rounded
                                         :max_height 25
                                         :desired_min_width 55
                                         :desired_min_height 12
                                         :winblend 5
                                         :scrollbar true}}
                :ghost_text {:enabled true}}
   :sources {:default [:lsp :path :buffer :copilot]
             :providers {:lsp {:name :LSP}
                         :path {:name :Path}
                         :buffer {:name :Buffer}
                         :copilot {:name :Copilot
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

(vim.schedule set-kind-hl)
(vim.api.nvim_create_autocmd :ColorScheme {:callback #(vim.schedule set-kind-hl)})
