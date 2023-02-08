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

(fmap :<A-1> ["n"] (bufferline.go_to_buffer 1 true))
(fmap :<A-2> ["n"] (bufferline.go_to_buffer 2 true))
(fmap :<A-3> ["n"] (bufferline.go_to_buffer 3 true))
(fmap :<A-4> ["n"] (bufferline.go_to_buffer 4 true))
(fmap :<A-5> ["n"] (bufferline.go_to_buffer 5 true))
(fmap :<A-6> ["n"] (bufferline.go_to_buffer 6 true))
(fmap :<A-7> ["n"] (bufferline.go_to_buffer 7 true))
(fmap :<A-8> ["n"] (bufferline.go_to_buffer 8 true))
(fmap :<A-9> ["n"] (bufferline.go_to_buffer 9 true))
(fmap :<A-q> ["n"] (bufferline.cycle -1))
(fmap :<A-w> ["n"] (bufferline.cycle 1))

