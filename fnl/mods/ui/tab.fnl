(module mods.ui.tab {
  autoload {
    bufferline bufferline }})

(bufferline.setup {
  :options {
    :mode "tabs"
    :show_duplicate_prefix false
    :numbers "ordinal"
    :show_close_icon false
    :show_buffer_close_icons false
    :diagnostics "nvim_lsp"}})

(map [:n :i :v :x] :<A-1> (bindf bufferline.go_to_buffer 1 true))
(map [:n :i :v :x] :<A-2> (bindf bufferline.go_to_buffer 2 true))
(map [:n :i :v :x] :<A-3> (bindf bufferline.go_to_buffer 3 true))
(map [:n :i :v :x] :<A-4> (bindf bufferline.go_to_buffer 4 true))

(map [:n :i :v :x] :<A-5> (bindf bufferline.go_to_buffer 5 true))
(map [:n :i :v :x] :<A-6> (bindf bufferline.go_to_buffer 6 true))
(map [:n :i :v :x] :<A-7> (bindf bufferline.go_to_buffer 7 true))
(map [:n :i :v :x] :<A-8> (bindf bufferline.go_to_buffer 8 true))

(map [:n :i :v :x] :<A-9> (bindf bufferline.go_to_buffer 9 true))
(map [:n :i :v :x] :<A-q> (bindf bufferline.cycle -1))
(map [:n :i :v :x] :<A-w> (bindf bufferline.cycle 1))

