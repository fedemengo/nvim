(module mods.ui.zenmode)

(fn onopen []
  (let [cmd (require :indent_blankline.commands)]
    (cmd.disable)))

(fn onclose []
  (let [cmd (require :indent_blankline.commands)]
    (cmd.enable)))

(let [zenmode (require :zen-mode)]
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
    :on_close onclose}))

