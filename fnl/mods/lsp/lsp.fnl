(module mods.lsp.lsp
  {autoload {
    cmp cmp
    cmp_nvim_lsp cmp_nvim_lsp
    luasnip luasnip
    lspkind lspkind
    mason mason
    mason-lspconfig mason-lspconfig
    masonnullls mason-null-ls
    which-key which-key}})

(cmp.setup {
  :snippet {
    :expand (fn [args] (luasnip.lsp_expand (. args :body)))}
  :window {
    :completion (cmp.config.window.bordered)
    :documentation (cmp.config.window.bordered)}
  :mapping (cmp.mapping.preset.insert {
    :<C-q> (cmp.mapping.scroll_docs -4)
    :<C-w> (cmp.mapping.scroll_docs 4)
    :<C-p> (cmp.mapping.select_prev_item cmp_select)
    :<C-n> (cmp.mapping.select_next_item cmp_select)
    :<C-e> (cmp.mapping.abort)
    :<C-y> (cmp.mapping.confirm {:select true})
    :<cr> (cmp.mapping.confirm {:select true})
    :<S-Tab> (cmp.mapping.complete)})
  :experimental {
    :native_menu false
    :ghost_text true}
  :sources (cmp.config.sources [
    { :name "nvim_lsp" }
    { :name "nvim_lua" }
    { :name "conjure" }
    { :name "path" }
    { :name "luasnip" }
    { :name "buffer" :keyword_length 5 }])
  :formatting {
    :format (lspkind.cmp_format {
      :mode "symbol_text"
      :maxwidth 50})}})

(cmp.setup.cmdline ["/" "?"] {
  :mapping (cmp.mapping.preset.cmdline)
  :sources [ {:name "buffer" }]})

(cmp.setup.cmdline [":"] {
  :mapping (cmp.mapping.preset.cmdline)
  :sources [ {:name "path"} {:name "cmdline"}]})

(mason.setup)
(mason-lspconfig.setup {
  :ensure_installed ["gopls" "clangd" "bashls" "dockerls" "sumneko_lua" "jsonls" "sqls" "pylsp" "jdtls"]
  :automatic_installation true})
(masonnullls.setup {:automatic_setup true})

(local on_attach (fn [client buf]
  (let [signature (require :lsp_signature)
        tbuiltin (require :telescope.builtin)
        bind (fn [f args] (fn [] (f args)))]
    (vim.api.nvim_buf_set_option buf "omnifunc" "v:lua.vim.lsp.omnifunc")
    (signature.on_attach {
      :bind true
      :handler_opts {:border "rounded"}
      :hint_enable false
    } buf)
    (which-key.register {
       "[d" [ vim.diagnostic.goto_prev                  "Prev diagnostic"]
       "]d" [ vim.diagnostic.goto_next                  "Next diagnostic"]
       :td  [ vim.lsp.buf.type_definition               "Type definition"]
       :gD  [ vim.lsp.buf.declaration                   "Goto declaration"]
       :gd  [ tbuiltin.lsp_definitions                  "Goto definition"]
       :gi  [ tbuiltin.lsp_implementations              "LSP implementations"]
       :gr  [ tbuiltin.lsp_references                   "Goto references"]
       :go  [ vim.diagnostic.open_float                 "Show diagnostics"]
       :K   [ vim.lsp.buf.hover                         "Hover"]
       :fk  [ (bind vim.lsp.buf.format {:async true} )  "Format code"]}
      {:noremap true :silent false :buffer buf }))))

(local lspconfig (require :lspconfig))
(local lsputil (require :lspconfig/util))
(local lspopts {
  :gopls {
    :autostart true
    :cmd ["gopls" "serve"]
    :filetypes ["go" "gomod"]
    :root_dir (lsputil.root_pattern "go.work" "go.mod" ".git")
    :settings {
      :gopls {
        :usePlaceholders true
        :buildFlags ["-tags=integration"]
        :gofumpt true
        :experimentalPostfixCompletions true
        :analyses {
          :nilness true
          :unusedparams true
          :unusedwrite true
          :useany true
          :fillstruct false}
        :codelenses {
          :gc_details true
          :generate true
          :test true}
        :staticcheck true
        :usePlaceholders true}}}
  :sumneko_lua {
    :settings {
      :Lua {:diagnostics {:globals ["vim"]}}}}
  :clangd {
    :autostart true
    :filetypes ["c" "cpp" "cuda"]}})

(let [get_servers (. mason-lspconfig :get_installed_servers)]
  (each [_ server (ipairs (get_servers))]
    (let [server_config (. lspconfig server)
          opts (or (. lspopts server) {})]
      (tset opts :on_attach on_attach)
      (tset opts :capabilites (cmp_nvim_lsp.default_capabilities))
      (server_config.setup opts))))

(let [nullls (require :null-ls)]
  (nullls.setup {
    :sources [
      nullls.builtins.formatting.stylua
      nullls.builtins.formatting.prettier]}))

