(module mods.ui.tab)

(let [bufferline (require :bufferline)]
  (bufferline.setup {
    :options {
      :mode "tabs"
      :show_duplicate_prefix false
      :numbers "ordinal"
      :show_close_icon false
      :show_buffer_close_icons false
      :diagnostics "nvim_lsp"}}))

