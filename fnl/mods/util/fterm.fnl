(module mods.util.fterm)

(let [fterm (require :FTerm)]
  (fterm.setup {
    :border "solid"
    :dimensions {
      :height 0.9
      :width 0.9 }}))

