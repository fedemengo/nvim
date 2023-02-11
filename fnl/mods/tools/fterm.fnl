(module mods.tools.fterm
  {autoload {
    fterm FTerm}})

(fterm.setup {
  :border "solid"
  :dimensions {
    :height 0.9
    :width 0.9 }})

(map [:n] :<leader>t  fterm.toggle  {:desc "Toggle FTerm"})
