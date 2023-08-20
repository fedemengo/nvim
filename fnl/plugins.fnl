(module plugins {autoload {packer :packer}})

(defn safe-require
  [mod]
  (let [(ok? val-or-err) (pcall require mod)]
    (if (not ok?)
        (print (.. "failed to load config for '" mod "': err stack\n"
                   val-or-err))
        val-or-err)))

(defn safe-mod-require [mod]
  (safe-require (.. :mods "." mod)))

(defn- use
  [...]
  (let [packs [...]]
    (packer.startup {1 (fn [use]
                         (for [i 1 (length packs) 2]
                           (let [name (. packs i) ;; plugin name
                                 opts (. packs (+ i 1))]
                             ;; plugin opts
                             (-?> (. opts :mod) (safe-mod-require))
                             ;; optional opts mods
                             (table.insert opts 1 name)
                             (use opts))))
                     :config {:display {:open_fn (. (require :packer.util)
                                                    :float)}}})))

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
     ;; ln -s ~/.local/share/nvim/site/pack/packer/opt/copilot.lua ~/.local/share/nvim/site/pack/packer/start/copilot.lua
     :zbirenbaum/copilot.lua {:cmd :Copilot
                             :event :InsertEnter
                             :mod :dev.copilot}
     :zbirenbaum/copilot-cmp {:mod :dev.copilot_cmp}
     ;; dev
     :rktjmp/hotpot.nvim {}
     :stevearc/profile.nvim {:mod :dev.profile}
     :ruifm/gitlinker.nvim {:requires [[:nvim-lua/plenary.nvim]] :mod :dev.gitlinker}
     ;; utils
     :folke/which-key.nvim {:mod :tools.which-key}
     :nvim-telescope/telescope-fzf-native.nvim {:run :make}
     :nvim-telescope/telescope.nvim {:requires [[:nvim-lua/popup.nvim] [:nvim-lua/plenary.nvim]] :mod :tools.telescope}
     :kevinhwang91/nvim-hlslens {:mod :ui.hlslens}
     :lukas-reineke/indent-blankline.nvim {:mod :ui.indentblank}
     :norcalli/nvim-colorizer.lua {:mod :ui.colorizer}
     :numToStr/FTerm.nvim {:mod :tools.fterm}
     ;;:SmiteshP/nvim-navic {}
     :nvim-tree/nvim-tree.lua {:mod :tools.nvim-tree}
     :jdhao/better-escape.vim {:mod :tools.better-escape}
     :mhinz/vim-startify {:mod :ui.startify}
     :karb94/neoscroll.nvim {:mod :ui.neoscroll}
     :ggandor/leap.nvim {:mod :tools.leap}
     :windwp/nvim-autopairs {}
     ;; theme
     :folke/zen-mode.nvim {:mod :ui.zenmode}
     :nvim-lualine/lualine.nvim {:mod :ui.lualine}
     :akinsho/bufferline.nvim {:requires [[:nvim-tree/nvim-web-devicons]] :mod :ui.tab}
     ;; programming
     :nvim-treesitter/nvim-treesitter {:run ":TSUpdate" :mod :tools.treesitter}
     :ray-x/go.nvim {:mod :dev.go_nvim}
     :lewis6991/gitsigns.nvim {:mod :tools.gitsigns}
     :ray-x/lsp_signature.nvim {}
     :simrat39/symbols-outline.nvim {:mod :lsp.symbols}
     :wakatime/vim-wakatime {}
     :Vonr/align.nvim {:mod :tools.align}
     :VonHeikemen/lsp-zero.nvim {:requires [[:neovim/nvim-lspconfig]
                                           [:williamboman/mason.nvim]
                                           [:williamboman/mason-lspconfig.nvim]
                                           [:jay-babu/mason-null-ls.nvim]
                                           [:hrsh7th/nvim-cmp]
                                           [:hrsh7th/cmp-buffer]
                                           [:hrsh7th/cmp-path]
                                           [:hrsh7th/cmp-cmdline]
                                           [:hrsh7th/cmp-nvim-lsp]
                                           [:hrsh7th/cmp-nvim-lua]
                                           [:onsails/lspkind.nvim]
                                           [:jose-elias-alvarez/null-ls.nvim]]
                                :mod :lsp.lsp})

(map [:n] :<space>pi packer.install {:desc "Install plugins"})
(map [:n] :<space>pu packer.update {:desc "Update plugins"})
(map [:n] :<space>pc packer.clean {:desc "Clean plugins"})
(map [:n] :<space>pC packer.compile {:desc "Compile plugins"})
