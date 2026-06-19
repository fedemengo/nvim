(module plugins)

(defn safe-require
  [mod]
  (let [(ok? val-or-err) (pcall require mod)]
    (if (not ok?)
        (print (.. "failed to load config for '" mod "': err stack\n"
                   val-or-err))
        val-or-err)))

(defn safe-mod-require [mod]
  (safe-require (.. :mods "." mod)))

(defn bootstrap-lazy
  []
  (let [lazypath (.. (vim.fn.stdpath :data) :/lazy/lazy.nvim)
        uv (or vim.uv vim.loop)]
    (when (not (uv.fs_stat lazypath))
      (vim.fn.system [:git
                      :clone
                      "--filter=blob:none"
                      "https://github.com/folke/lazy.nvim.git"
                      :--branch=stable
                      lazypath])
      (when (not (= 0 vim.v.shell_error))
        (error "failed to bootstrap lazy.nvim")))
    (vim.opt.rtp:prepend lazypath)))

(defn use
  [...]
  (let [packs [...]
        specs []]
    (for [i 1 (length packs) 2]
      (let [name (. packs i)
            spec (or (. packs (+ i 1)) {})]
        (tset spec 1 name)
        (when spec.mod
          (let [m spec.mod]
            (tset spec :config (fn [] (safe-mod-require m)))
            (tset spec :mod nil)))
        (table.insert specs spec)))
    (bootstrap-lazy)
    (let [lazy (safe-require :lazy)]
      (when lazy
        ;; disable rtp reset: lazy's reset guesses lib64 over lib/nvim,
        ;; dropping bundled treesitter parsers on some distros
        (lazy.setup specs
                    {:ui {:border :rounded} :performance {:rtp {:reset false}}})))))

(use
  ;; bootstrap
  :Olical/aniseed {}
  ;; colorschemes
  :NLKNguyen/papercolor-theme {}
  :projekt0n/github-nvim-theme {}
  :catppuccin/nvim {}
  :AlexvZyl/nordic.nvim {}
  :loctvl842/monokai-pro.nvim {:mod :ui.monokai}
  ;; ui chrome
  :nvim-lualine/lualine.nvim {}
  :arkav/lualine-lsp-progress {:mod :ui.lualine}
  :akinsho/bufferline.nvim {:dependencies [:nvim-tree/nvim-web-devicons] :mod :ui.tab}
  :SmiteshP/nvim-navic {}
  :nvim-focus/focus.nvim {:mod :ui.focus}
  :goolord/alpha-nvim {:mod :ui.alpha}
  :rcarriga/nvim-notify {:mod :ui.notify}
  ;; motion
  :ggandor/leap.nvim {:url "https://codeberg.org/andyg/leap.nvim" :mod :tools.leap}
  :wellle/targets.vim {}
  :folke/which-key.nvim {:mod :tools.which-key}
  ;; file explorer
  :stevearc/oil.nvim {:dependencies [:nvim-tree/nvim-web-devicons] :mod :tools.oil}
  ;; lsp + completion
  :VonHeikemen/lsp-zero.nvim {:dependencies [:neovim/nvim-lspconfig
                                             :williamboman/mason.nvim
                                             :williamboman/mason-lspconfig.nvim
                                             :jay-babu/mason-null-ls.nvim
                                             :nvimtools/none-ls.nvim]
                              :mod :lsp.lsp}
  :saghen/blink.lib {}
  :saghen/blink.cmp {:build (fn [] (: ((. (require :blink.cmp) :build)) :pwait))
                     :dependencies [:giuxtaposition/blink-cmp-copilot
                                    :saghen/blink.lib]
                     :mod :lsp.blink}
  :ray-x/lsp_signature.nvim {}
  :wakatime/vim-wakatime {}
  ;; treesitter
  :nvim-treesitter/nvim-treesitter {:build ":TSUpdate" :mod :tools.treesitter}
  ;; copilot
  :zbirenbaum/copilot.lua {:event :InsertEnter :mod :dev.copilot}
  ;; insert-mode only
  :windwp/nvim-autopairs {:event :InsertEnter}
  :jdhao/better-escape.vim {:event :InsertEnter :mod :tools.better-escape}
  ;; buffer decorations
  :lewis6991/gitsigns.nvim {:event [:BufRead :BufNewFile] :mod :tools.gitsigns}
  :RRethy/vim-illuminate {:event :LspAttach :mod :tools.illuminate}
  :kevinhwang91/nvim-hlslens {:event [:BufRead :BufNewFile] :mod :ui.hlslens}
  :lukas-reineke/indent-blankline.nvim {:event [:BufRead :BufNewFile] :main :ibl :mod :ui.indentblank}
  :catgoose/nvim-colorizer.lua {:event [:BufRead :BufNewFile] :mod :ui.colorizer}
  :karb94/neoscroll.nvim {:event [:BufRead :BufNewFile] :mod :ui.neoscroll}
  :sphamba/smear-cursor.nvim {:event :VeryLazy :mod :ui.smear-cursor}
  :petertriho/nvim-scrollbar {:event [:BufRead :BufNewFile] :mod :ui.scrollbar}
  :folke/todo-comments.nvim {:event [:BufRead :BufNewFile] :dependencies [:nvim-lua/plenary.nvim] :mod :tools.todo-comments}
  :MeanderingProgrammer/render-markdown.nvim {:ft [:markdown :Avante] :mod :ui.render-markdown}
  ;; filetype-specific
  :ray-x/go.nvim {:ft [:go :gomod :gowork] :mod :dev.go_nvim}
  :Julian/lean.nvim {:ft [:lean] :dependencies [:neovim/nvim-lspconfig] :mod :dev.lean}
  ;; commands
  :folke/trouble.nvim {:cmd [:Trouble :TroubleToggle] :mod :tools.trouble}
  :folke/zen-mode.nvim {:cmd :ZenMode :mod :ui.zenmode}
  :hedyhli/outline.nvim {:cmd :Outline :mod :lsp.symbols}
  :esmuellert/codediff.nvim {:cmd :CodeDiff :mod :tools.codediff}
  :numToStr/FTerm.nvim {:cmd :FTerm :mod :tools.fterm}
  ;; deferred
  :nvim-telescope/telescope.nvim {:event :VeryLazy
                                  :dependencies [:nvim-lua/popup.nvim
                                                 :nvim-lua/plenary.nvim]
                                  :mod :tools.telescope}
  :nvim-telescope/telescope-fzf-native.nvim {:build :make}
  :nvim-telescope/telescope-media-files.nvim {}
  :sopa0/telescope-makefile {:dependencies [:akinsho/toggleterm.nvim]}
  :ruifm/gitlinker.nvim {:event :VeryLazy :dependencies [:nvim-lua/plenary.nvim] :mod :dev.gitlinker}
  :Vonr/align.nvim {:event :VeryLazy :mod :tools.align}
  :folke/persistence.nvim {:event :VeryLazy :mod :tools.persistence}
  :stevearc/profile.nvim {:event :VeryLazy :mod :dev.profile}
  :yetone/avante.nvim {:event :VeryLazy
                       :dependencies [:nvim-treesitter/nvim-treesitter
                                      :HakonHarnes/img-clip.nvim
                                      :stevearc/dressing.nvim
                                      :nvim-lua/plenary.nvim
                                      :MunifTanjim/nui.nvim
                                      :nvim-tree/nvim-web-devicons]
                       :build :make
                       :mod :dev.avante}
  ;; dap
  :mfussenegger/nvim-dap {:cmd [:DapContinue
                               :DapToggleBreakpoint
                               :DapNew
                               :DapStepOver
                               :DapStepInto]}
  :mfussenegger/nvim-dap-python {:ft :python :dependencies [:mfussenegger/nvim-dap]}
  :rcarriga/nvim-dap-ui {:cmd [:DapContinue :DapToggleBreakpoint] :dependencies [:mfussenegger/nvim-dap :nvim-neotest/nvim-nio]}
  :jay-babu/mason-nvim-dap.nvim {:cmd [:DapContinue :DapToggleBreakpoint] :dependencies [:williamboman/mason.nvim :mfussenegger/nvim-dap] :mod :dev.dap}
  ;; misc
  :gruvw/strudel.nvim {:build "npm install" :mod :misc.strudel})

(map [:n] :<space>pi ":Lazy install<cr>" {:desc "Install plugins"})
(map [:n] :<space>pu ":Lazy update<cr>" {:desc "Update plugins"})
(map [:n] :<space>pc ":Lazy clean<cr>" {:desc "Clean plugins"})
(map [:n] :<space>pC ":Lazy sync<cr>" {:desc "Sync plugins"})
