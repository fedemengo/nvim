(module :mods.lsp.lsp
        {autoload {navic nvim-navic
                   cmp cmp
                   cmp_nvim_lsp cmp_nvim_lsp
                   lspkind lspkind
                   lspsignature lsp_signature
                   lspconfig lspconfig
                   lsputil lspconfig/util
                   nullls null-ls
                   mason mason
                   masonlsp mason-lspconfig
                   masonnullls mason-null-ls
                   themes telescope.themes
                   tbuiltin telescope.builtin}})

(cmp.setup {:window {:completion (cmp.config.window.bordered)
                     :documentation (cmp.config.window.bordered)}
            :mapping (cmp.mapping.preset.insert {:<C-q> (cmp.mapping.scroll_docs -4)
                                                 :<C-w> (cmp.mapping.scroll_docs 4)
                                                 :<C-p> (cmp.mapping.select_prev_item cmp_select)
                                                 :<C-n> (cmp.mapping.select_next_item cmp_select)
                                                 :<C-e> (cmp.mapping.abort)
                                                 :<C-y> (cmp.mapping.confirm {:select true
                                                                              :behavior cmp.ConfirmBehavior.Replace})
                                                 :<S-Tab> (cmp.mapping.complete)})
            :experimental {:native_menu false :ghost_text true}
            :sources (cmp.config.sources [{:name :copilot}
                                          {:name :nvim_lsp}
                                          {:name :nvim_lua}
                                          {:name :conjure}
                                          {:name :path}
                                          {:name :buffer :keyword_length 5}])
            :formatting {:format (lspkind.cmp_format {:mode :symbol_text
                                                      :maxwidth 50})}})

(cmp.setup.cmdline ["/" "?"]
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources [{:name :buffer}]})

(cmp.setup.cmdline [":"]
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources [{:name :path} {:name :cmdline}]})

(mason.setup {:PATH :append})
(masonlsp.setup {:ensure_installed [:gopls
                                    ;:fennel_language_server
                                    :clangd
                                    :bashls
                                    :dockerls
                                    :lua_ls
                                    :jsonls
                                    :sqlls
                                    :pylsp
                                    :jdtls
                                    :rust_analyzer]
                 :automatic_installation true})

(let [fmt nullls.builtins.formatting]
  (nullls.setup {:sources [fmt.black
                           fmt.stylua
                           fmt.fnlfmt
                           fmt.shfmt
                           fmt.goimports
                           fmt.gofumpt
                           fmt.prettier]}))

(masonnullls.setup {:handlers {}})

(local on_attach
       (fn [client buf]
         (vim.api.nvim_buf_set_option buf :omnifunc "v:lua.vim.lsp.omnifunc")
         (navic.attach client buf)
         (lspsignature.on_attach {:bind true
                                  :handler_opts {:border :rounded}
                                  :hint_enable false}
                                 buf)
         (map [:n] :<leader>cw vim.lsp.buf.rename
              {:desc "Rename symbol [LSP]" :buffer buf})
         (map [:n :v] :<leader>ca vim.lsp.buf.code_action
              {:desc "Code actions [LSP]" :buffer buf})
         (map [:n] :gt vim.lsp.buf.type_definition
              {:desc "Type definition [LSP]" :buffer buf})
         (map [:n] :gD vim.lsp.buf.declaration
              {:desc "Go to declaration [LSP]" :buffer buf})
         (map [:n] :K vim.lsp.buf.hover {:desc "Hover [LSP]" :buffer buf})
         (map [:n] :fk (bindf vim.lsp.buf.format {:async true})
              {:desc "Format code [LSP]" :buffer buf})
         (map [:n] "]d" vim.diagnostic.goto_prev
              {:desc "Next diagnostic" :buffer buf})
         (map [:n] "[s" vim.diagnostic.show
              {:desc "Show diagnostic" :buffer buf})
         (map [:n] "[h" vim.diagnostic.hide
              {:desc "Hide diagnostic" :buffer buf})
         (map [:n] :go vim.diagnostic.open_float
              {:desc "Open diagnostic" :buffer buf})))

(local lsp_opt {:gopls {:autostart true
                        :cmd [:gopls :serve]
                        :filetypes [:go :mod]
                        :root_dir (lsputil.root_pattern :go.mod :.git)
                        :flags {:allow_incremental_sync true
                                :debounce_text_changes 1000}
                        :settings {:gopls {:completeUnimported true
                                           :buildFlags ["-tags=integration,unit,opensearch"]
                                           :gofumpt true
                                           :experimentalPostfixCompletions true
                                           :analyses {:nilness true
                                                      :unusedparams true
                                                      :unusedwrite true
                                                      :unusedvariable true
                                                      :shadow true
                                                      :useany true
                                                      :assign true
                                                      :bools true
                                                      :defers true
                                                      :deprecated true
                                                      :errorsas true
                                                      :httpresponse true
                                                      :ifaceassert true
                                                      :loopclosure true
                                                      :lostcancel true
                                                      :simplifyrange true
                                                      :simplifyslice true
                                                      :structtag true
                                                      :fieldalignment false}
                                           :codelenses {:gc_details true
                                                        :generate true
                                                        :test true}
                                           :staticcheck true
                                           :usePlaceholders true}}}
                :lua_ls {:settings {:Lua {:diagnostics {:globals [:vim]}}}}
                ;:fennel_language_server {:default_config {:cmd [:$HOME/.local/bin/fennel-language-server]
                ;                                          :filetypes [:fennel]
                ;                                          :single_file_support true
                ;                                          :root_dir (lsputil.root_pattern :fnl)
                ;                                          :settings {:fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                ;                                                              :diagnostics {:globals [:vim
                ;                                                                                      :module
                ;                                                                                      :autoload]}}}}}
                :pylsp {:settings {:pylsp {:plugins {:pycodestyle {:enable false
                                                                   :ignore [;; continuation line indentation is not a multiple of four
                                                                            :E121
                                                                            ;; expected 2 blank lines, found 1
                                                                            :E302
                                                                            ;; line too long
                                                                            :E501
                                                                            ;; allow multiple stms in the same line
                                                                            :E701
                                                                            ;; line break before binary operator
                                                                            :W503]
                                                                   :indentSize 4}
                                                     :autopep8 {:enable false}
                                                     :yapf {:enable false}
                                                     :black {:enabled true}
                                                     :pylsp_mypy {:enabled true
                                                                  :live_mode true}}}}
                        :plugins {:rope_autoimport {:enabled true}}}
                :clangd {:autostart true
                         :capabilities {:offsetEncoding :utf-8}
                         :filetypes [:c :cpp :cuda]}})

(let [get_servers (. masonlsp :get_installed_servers)]
  (each [_ server (ipairs (get_servers))]
    (let [opts (or (. lsp_opt server) {})]
      (tset opts :on_attach on_attach)
      (tset opts :capabilites (cmp_nvim_lsp.default_capabilities))
      (vim.lsp.config server opts))))

