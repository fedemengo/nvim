(module mods.ui.tab {
  autoload {
    bufferline bufferline }})

(import-macros { :def-keymap-fn fmap }
  :zest.macros )

(bufferline.setup {
  :options {
    :mode "tabs"
    :show_duplicate_prefix false
    :numbers "ordinal"
    :show_close_icon false
    :show_buffer_close_icons false
    :diagnostics "nvim_lsp"}})

(fmap :¡ ["n"] (bufferline.go_to_buffer 1 true))
(fmap :™ ["n"] (bufferline.go_to_buffer 2 true))
(fmap :£ ["n"] (bufferline.go_to_buffer 3 true))
(fmap :¢ ["n"] (bufferline.go_to_buffer 4 true))
(fmap :∞ ["n"] (bufferline.go_to_buffer 5 true))
(fmap :§ ["n"] (bufferline.go_to_buffer 6 true))
(fmap :¶ ["n"] (bufferline.go_to_buffer 7 true))
(fmap :• ["n"] (bufferline.go_to_buffer 8 true))
(fmap :ª ["n"] (bufferline.go_to_buffer 9 true))

