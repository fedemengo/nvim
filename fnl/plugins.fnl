(module plugins
  {autoload {
    packer packer }})

(defn safe-require [mod]
  (let [(ok? val-or-err) (pcall require mod)]
    (if (not ok?)
      (print (.. "failed to load config for '" mod "': err stack\n" val-or-err))
      val-or-err)))

(defn safe-mod-require [mod]
  (safe-require (.. :mods "." mod)))

(defn- use [...]
  (let [packs [...]]
    (packer.startup
      {1 (fn [use]
            (for [i 1 (length packs) 2]
              (let [name (. packs i)                ;; plugin name
                    opts (. packs (+ i 1))]         ;; plugin opts
                (-?> (. opts :mod) (safe-mod-require))  ;; optional opts mods
                (table.insert opts 1 name)
                (use opts))))
       :config {
        :display {
          :open_fn (. (require :packer.util) :float)}}})))

;; setup is used for inline setup for modules that require no or {} arg
(fn setup [...]
    (let [in [...]]
      (let [name (. in 1)
            plugin (safe-require name)]
        (when plugin
          (if (= 2 (length in))
            (let [arg (. in 2)]
              (plugin.setup arg))
            (plugin.setup))))))

(use
    ;; ensured
    :wbthomason/packer.nvim {}
    :Olical/aniseed {}
    :lewis6991/impatient.nvim {}
    :NLKNguyen/papercolor-theme {}
    :fedemengo/github-nvim-theme {}

    :zbirenbaum/copilot.lua {:cmd "Copilot" :event "InsertEnter" :config (setup "copilot" {:suggestion { :enabled false }
                                                                                           :panel { :enabled false }})}
    :zbirenbaum/copilot-cmp {:config (setup "copilot_cmp")}

    ;; dev
    :rktjmp/hotpot.nvim {}

    ;; utils
    :folke/which-key.nvim {:config (setup "which-key") }
    :nvim-telescope/telescope-fzf-native.nvim {:run "make" }
    :nvim-telescope/telescope.nvim {
      :requires [
        [:nvim-lua/popup.nvim]
        [:nvim-lua/plenary.nvim]]
      :mod :tools.telescope }
    :kevinhwang91/nvim-hlslens {:config (setup "hlslens") }
    :lukas-reineke/indent-blankline.nvim {:mod :ui.indentblank }
    :norcalli/nvim-colorizer.lua {:config (setup "colorizer") }
    :numToStr/FTerm.nvim {:mod :tools.fterm }
    :SmiteshP/nvim-gps {}
    :nvim-tree/nvim-tree.lua {:mod :tools.nvim-tree }

    :jdhao/better-escape.vim {:mod :tools.better-escape }
    :mhinz/vim-startify {:mod :ui.startify }
    :karb94/neoscroll.nvim {:mod :ui.neoscroll }
    :ggandor/leap.nvim {:config (setup "leap" {}) }
    :windwp/nvim-autopairs {}

    ;; theme
    :folke/zen-mode.nvim {:mod :ui.zenmode }
    :nvim-lualine/lualine.nvim {:mod :ui.lualine }
    :akinsho/bufferline.nvim {
      :requires [
        [:nvim-tree/nvim-web-devicons]] :mod :ui.tab }

    ;; programming
    :nvim-treesitter/nvim-treesitter {:run ":TSUpdate" :mod :tools.treesitter }
    :fatih/vim-go {:run ":GoUpdateBinaries" }
    :lewis6991/gitsigns.nvim {:mod :tools.gitsigns }
    :ray-x/lsp_signature.nvim {}
    :wakatime/vim-wakatime {}

    :VonHeikemen/lsp-zero.nvim {
      :requires [
        [:neovim/nvim-lspconfig]
        [:williamboman/mason.nvim]
        [:williamboman/mason-lspconfig.nvim]
        [:jay-babu/mason-null-ls.nvim]

        [:hrsh7th/nvim-cmp]
        [:hrsh7th/cmp-buffer]
        [:hrsh7th/cmp-path]
        [:hrsh7th/cmp-cmdline]
        [:saadparwaiz1/cmp_luasnip]
        [:hrsh7th/cmp-nvim-lsp]
        [:hrsh7th/cmp-nvim-lua]

        [:onsails/lspkind.nvim]
        [:L3MON4D3/LuaSnip]
        [:rafamadriz/friendly-snippets]
        [:jose-elias-alvarez/null-ls.nvim]]
      :mod :lsp.lsp })

(map [:n] :<space>pi packer.install {:desc "Install plugins"})
(map [:n] :<space>pu packer.update  {:desc "Update plugins"})
(map [:n] :<space>pc packer.clean   {:desc "Clean plugins"})
(map [:n] :<space>pC packer.compile {:desc "Compile plugins"})

