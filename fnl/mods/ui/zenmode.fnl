(module mods.ui.zenmode {autoload {zenmode zen-mode}})

(fn onopen []
  (vim.cmd "IBLDisable"))

(fn onclose []
  (vim.cmd "IBLEnable"))

(zenmode.setup {:window {:backdrop 1
                         :width 0.75
                         :height 0.95
                         :options {:signcolumn :no
                                   :cursorline false
                                   :cursorcolumn false
                                   :list false}}
                :plugins {:gitsigns {:enabled false}}
                :on_open onopen
                :on_close onclose})

(map [:n] :<leader>Z zenmode.toggle {:desc "Toggle zen mode"})
