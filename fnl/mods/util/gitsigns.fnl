(module mods.util.gitsigns
  {autoload {
    gitsigns gitsigns
    wkey which-key }})

(gitsigns.setup {
  :signs {
    :add { :hl "GitSignsAdd" :text "+" :numhl "GitSignsAddNr" :linehl "GitSignsAddLn" }
    :change { :hl "GitSignsChange" :text "~" :numhl "GitSignsChangeNr" :linehl "GitSignsChangeLn" }
    :changedelete { :hl "GitSignsChange" :text "~" :numhl "GitSignsChangeNr" :linehl "GitSignsChangeLn" }
    :delete { :hl "GitSignsDelete" :text "-" :numhl "GitSignsChangeNr" :linehl "GitSignsChangeLn" }
    :topdelete { :hl "GitSignsDelete" :text "-" :numhl "GitSignsChangeNr" :linehl "GitSignsChangeLn" }}
  :current_line_blame false
  :current_line_blame_formatter "     <author> | <author_time:%a %d/%m/%y %X> | <summary> "
  :current_line_blame_opts {
    :virt_text true
    :virt_text_pos "eol"
    :delay 100
    :ignore_whitespace false}})

(wkey.register
  { :b [gitsigns.toggle_current_line_blame "Toggle git blame"]}
  { :prefix "<leader>" })

