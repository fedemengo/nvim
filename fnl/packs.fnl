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
    ;; utils
    :nvim-telescope/telescope.nvim {:requires [[:nvim-lua/popup.nvim] [:nvim-lua/plenary.nvim]] :mod :util.telescope}

    :jdhao/better-escape.vim {:mod :util.better-escape}
    :mhinz/vim-startify {:mod :util.startify}
    :karb94/neoscroll.nvim {:mod :util.neoscroll}

    ;; theme
    :NLKNguyen/papercolor-theme {}
    :folke/zen-mode.nvim {}

    ;; programming
    :nvim-treesitter/nvim-treesitter {:run ":TSUpdate" :mod :util.treesitter}

    :fatih/vim-go {:run ":GoUpdateBinaries" }
)
