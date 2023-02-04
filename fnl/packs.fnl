(module packs
  {autoload {packer packer}})

(defn safe-require [mod]
  (let [(ok? val-or-err) (pcall require (.. :mods. mod))]
    (when (not ok?)
      (print (.. "failed to load config for 'mods." mod "': " val-or-err)))))

(defn- use [...]
  (let [packs [...]]
    (packer.startup
      {1 (fn [use]
            (for [i 1 (length packs) 2]
              (let [name (. packs i)                ;; plugin name
                    opts (. packs (+ i 1))]         ;; plugin opts
                (-?> (. opts :mod) (safe-require))  ;; optional opts mods
                (table.insert opts 1 name)
                (use opts))))
       :config {:display {:open_fn (. (require :packer.util) :float)}}})))

;; setup is used for inline setup for modules that require no or {} arg
(fn setup [...]
    (let [in [...]
          name (. in 1)
          plugin (require name)]
      (if (= 2 (length in))
        (let [arg (. in 2)]
          (plugin.setup arg))
        (plugin.setup))))

(use
    ;; ensured
    :wbthomason/packer.nvim {}
    :Olical/aniseed {}
    :lewis6991/impatient.nvim {}
    :tsbohc/zest.nvim {}

    ;; utils
    :nvim-telescope/telescope.nvim {
      :requires [
        [:nvim-lua/popup.nvim]
        [:nvim-lua/plenary.nvim]
        [:nvim-telescope/telescope-fzf-native.nvim {:run "make" }]]
      :mod :util.telescope }
    :folke/which-key.nvim {}
    :kevinhwang91/nvim-hlslens {:config (setup "hlslens") }
    :lukas-reineke/indent-blankline.nvim {:mod :ui.indentblank }
    :norcalli/nvim-colorizer.lua {:config (setup "colorizer") }
    :numToStr/FTerm.nvim {:mod :util.fterm }
    :SmiteshP/nvim-gps {}
    :nvim-tree/nvim-tree.lua {:config (setup "nvim-tree") }

    :jdhao/better-escape.vim {:mod :util.better-escape }
    :mhinz/vim-startify {:mod :ui.startify }
    :karb94/neoscroll.nvim {:mod :ui.neoscroll }
    :ggandor/leap.nvim {:config (setup "leap" {}) }
    :windwp/nvim-autopairs {}

    ;; theme
    :NLKNguyen/papercolor-theme {}
    :folke/zen-mode.nvim {:mod :ui.zenmode }
    :nvim-lualine/lualine.nvim {:mod :ui.lualine }
    :akinsho/bufferline.nvim {:requires [[:nvim-tree/nvim-web-devicons]] :mod :ui.tab }

    ;; programming
    :nvim-treesitter/nvim-treesitter {:run ":TSUpdate" :mod :util.treesitter }
    :fatih/vim-go {:run ":GoUpdateBinaries" }
    :lewis6991/gitsigns.nvim {:mod :util.gitsigns }
    :ray-x/lsp_signature.nvim {}

    :VonHeikemen/lsp-zero.nvim {
      :requires [
        [:neovim/nvim-lspconfig]
        [:williamboman/mason.nvim]
        [:jay-babu/mason-null-ls.nvim]
        [:williamboman/mason-lspconfig.nvim]

        [:hrsh7th/nvim-cmp]
        [:hrsh7th/cmp-buffer]
        [:hrsh7th/cmp-path]
        [:saadparwaiz1/cmp_luasnip]
        [:hrsh7th/cmp-nvim-lsp]
        [:hrsh7th/cmp-nvim-lua]

        [:onsails/lspkind.nvim]
        [:L3MON4D3/LuaSnip]
        [:rafamadriz/friendly-snippets]
        [:jose-elias-alvarez/null-ls.nvim]]
      :mod :lsp.lsp })

(local which-key (require :which-key))
(which-key.register
  {
    :p {
      :name "plugins"
      :i [packer.install "Install plugins"]
      :u [packer.update "Update plugins"]
      :c [packer.compile "Compile packer file"]
      :C [packer.clean "Clean plugins"]}}
  {
   :prefix "<space>" })

