(module mods.ui.zenmode
  {autoload {
    cmd indent_blankline.commands
    zenmode zen-mode }})

(fn onopen []
  (cmd.disable))

(fn onclose []
  (cmd.enable))

(zenmode.setup {
  :window {
    :backdrop 1
    :options {
      :signcolumn "no"
      :cursorline false
      :cursorcolumn false
      :list false}
    }
  :plugins {
    :gitsigns {:enabled false}}
  :on_open onopen
  :on_close onclose})

(map [:n] :<leader>zz zenmode.toggle {:desc "Toggle zen mode"})

