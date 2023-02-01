(module packs
  {autoload {packer packer}}
)

(defn safe-require [mod]
  (let [(ok? val-or-err) (pcall require (.. :mods. mod))]
    (when (not ok?)
      (print (.. "failed to load config for 'mods." mod "': " val-or-err))
    )
  )
)

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
       :config {:display {:open_fn (. (require :packer.util) :float)}}}
    )
  )
  nil
)

(use
    ;; ensured
    :wbthomason/packer.nvim {}
    :Olical/aniseed {}
    :lewis6991/impatient.nvim {}

    ;; utils
    :nvim-telescope/telescope.nvim {:requires [[:nvim-lua/popup.nvim] [:nvim-lua/plenary.nvim]] :mod :util.telescope}
    :folke/which-key.nvim {}
    :kevinhwang91/nvim-hlslens {:mod :util.hlslens }

    :jdhao/better-escape.vim {:mod :util.better-escape}
    :mhinz/vim-startify {:mod :util.startify}
    :karb94/neoscroll.nvim {:mod :util.neoscroll}

    ;; theme
    :NLKNguyen/papercolor-theme {}
    :folke/zen-mode.nvim {}
    :nvim-lualine/lualine.nvim {:mod :util.lualine}
    :akinsho/bufferline.nvim {:requires [[:nvim-tree/nvim-web-devicons]] :mod :util.tab }

    ;; programming
    :nvim-treesitter/nvim-treesitter {:run ":TSUpdate" :mod :util.treesitter}
    :fatih/vim-go {:run ":GoUpdateBinaries" }
    :lewis6991/gitsigns.nvim {:mod :util.gitsigns}

    :VonHeikemen/lsp-zero.nvim {
      :requires [
        [:neovim/nvim-lspconfig]
        [:williamboman/mason.nvim]
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
        [:jose-elias-alvarez/null-ls.nvim]
      ]
      :mod :lsp.lsp
  }
)
