(module :mods.lsp.lsp
        {autoload {navic nvim-navic
                   cmp cmp
                   cmp_nvim_lsp cmp_nvim_lsp
                   lspkind lspkind
                   lspsignature lsp_signature
                   lsputil lspconfig/util
                   nullls null-ls
                   mason mason
                   masonlsp mason-lspconfig
                   masonnullls mason-null-ls
                   themes telescope.themes
                   tbuiltin telescope.builtin}})

;; selection behavior for cmp mappings

(local cmp_select {:behavior cmp.SelectBehavior.Select})

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
                    :sources (cmp.config.sources [{:name :path}]
                                                 [{:name :cmdline}])})

(mason.setup {:PATH :append})
(masonlsp.setup {:ensure_installed [;:gopls
                                    ;:fennel_language_server
                                    :clangd
                                    :bashls
                                    :dockerls
                                    :lua_ls
                                    :jsonls
                                    :sqlls
                                    :pylsp
                                    :pyright
                                    :jdtls
                                    :rust_analyzer]
                 :automatic_enable false})

(let [fmt nullls.builtins.formatting]
  (nullls.setup {:sources [fmt.black
                           fmt.stylua
                           fmt.fnlfmt
                           fmt.shfmt
                           fmt.goimports
                           fmt.gofumpt
                           fmt.prettier]}))

(masonnullls.setup {:handlers {}})

(map [:n] :fk (bindf vim.lsp.buf.format {:async false})
     {:desc "Format code [LSP]"})

(var clangd_hints_enabled (or vim.g.clangd_hints_enabled false))
(set vim.g.clangd_hints_enabled clangd_hints_enabled)

(local clangd_filetypes [:c :cpp :cuda])

(local clangd_cmd
       (fn []
         (if clangd_hints_enabled
             [:clangd "--function-arg-placeholders=true" "--inlay-hints=true"]
             [:clangd "--function-arg-placeholders=false" "--inlay-hints=false"])))

(local restart_clangd
       (fn []
         (each [_ client (ipairs (vim.lsp.get_clients {:name :clangd}))]
           ;; graceful shutdown avoids non-zero "killed" exit warnings
           (client.stop false))
         (when (vim.tbl_contains clangd_filetypes vim.bo.filetype)
           (vim.defer_fn (fn []
                           (vim.lsp.enable :clangd))
                         120))))

(local on_attach
       (fn [client buf]
         (when (= client.name :pylsp)
           (tset client.server_capabilities :documentFormattingProvider false)
           (tset client.server_capabilities :documentRangeFormattingProvider false))
         ;; ruff can attach to Python buffers but doesn't provide rich symbol hover docs.
         ;; keep hover owned by pylsp so `K` shows Python docstrings on usages/calls.
         (when (= client.name :ruff)
           (tset client.server_capabilities :hoverProvider false)
           (tset client.server_capabilities :definitionProvider false)
           (tset client.server_capabilities :referencesProvider false))
         (vim.api.nvim_buf_set_option buf :omnifunc "v:lua.vim.lsp.omnifunc")
         (when client.server_capabilities.documentSymbolProvider
           (navic.attach client buf))
         (when (= client.name :clangd)
           (when (and vim.lsp.inlay_hint vim.lsp.inlay_hint.enable)
             (vim.lsp.inlay_hint.enable clangd_hints_enabled {:bufnr buf})))
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
         (map [:n] :gd vim.lsp.buf.definition
              {:desc "Go to definition [LSP]" :buffer buf})
         (map [:n] :gD vim.lsp.buf.declaration
              {:desc "Go to declaration [LSP]" :buffer buf})
         (map [:n] :K vim.lsp.buf.hover {:desc "Hover [LSP]" :buffer buf})
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
                        :filetypes [:go :gomod :gowork]
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
                :lua_ls {:filetypes [:lua]
                         :settings {:Lua {:diagnostics {:globals [:vim]}}}}
                ;:fennel_language_server {:default_config {:cmd [:$HOME/.local/bin/fennel-language-server]
                ;                                          :filetypes [:fennel]
                ;                                          :single_file_support true
                ;                                          :root_dir (lsputil.root_pattern :fnl)
                ;                                          :settings {:fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                ;                                                              :diagnostics {:globals [:vim
                ;                                                                                      :module
                ;                                                                                      :autoload]}}}}}
                :pylsp {:filetypes [:python]
                        :settings {:pylsp {:plugins {:pycodestyle {:enable false
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
                                                     ;; Force-enable Jedi language features for hover/definitions/references.
                                                     :jedi_hover {:enabled true}
                                                     :jedi_definition {:enabled true}
                                                     :jedi_references {:enabled true}
                                                     :jedi_symbols {:enabled true}
                                                     :autopep8 {:enable false}
                                                     :yapf {:enable false}
                                                     :black {:enabled true}
                                                     :pylsp_mypy {:enabled true
                                                                  :live_mode true}}}}
                        :plugins {:rope_autoimport {:enabled true}}}
                :pyright {:filetypes [:python]
                          :before_init (fn [_ config]
                                         (let [python (.. config.root_dir "/.venv/bin/python")]
                                           (when (= 1 (vim.fn.executable python))
                                             (tset config.settings.python :pythonPath python))))
                          :settings {:python {:analysis {:autoSearchPaths true
                                                         :extraPaths ["src"]
                                                         :useLibraryCodeForTypes true
                                                         :diagnosticMode :openFilesOnly}}}}
                :bashls {:filetypes [:bash :sh :zsh]}
                :dockerls {:filetypes [:dockerfile]}
                :jsonls {:filetypes [:json :jsonc]}
                :sqlls {:filetypes [:sql]}
                :jdtls {:filetypes [:java]}
                :rust_analyzer {:filetypes [:rust]}
                :clangd {:autostart true
                         :cmd (clangd_cmd)
                         :capabilities {:offsetEncoding :utf-8}
                         :filetypes [:c :cpp :cuda]}})

(local default_lsp_capabilities (cmp_nvim_lsp.default_capabilities))

(local prefer_pyright (= 1 (vim.fn.executable :pyright-langserver)))

(each [server opts (pairs lsp_opt)]
  (when (not (and prefer_pyright (= server :pylsp)))
    (let [server_opts (vim.deepcopy opts)]
      (tset server_opts :on_attach on_attach)
      (tset server_opts :capabilities (vim.tbl_deep_extend :force
                                                            default_lsp_capabilities
                                                            (or (. server_opts :capabilities) {})))
      (vim.lsp.config server server_opts)
      (vim.lsp.enable server))))

(vim.api.nvim_create_user_command :ClangdHintsToggle
                                  (fn []
                                    (set clangd_hints_enabled
                                         (not clangd_hints_enabled))
                                    (set vim.g.clangd_hints_enabled
                                         clangd_hints_enabled)
                                    (tset (. lsp_opt :clangd) :cmd
                                          (clangd_cmd))
                                    (restart_clangd)
                                    (vim.notify (if clangd_hints_enabled
                                                    "clangd hints/placeholders: ON"
                                                    "clangd hints/placeholders: OFF")))
                                  {})


