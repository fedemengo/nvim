(module mods.tools.align
  {autoload {
    align align}})

(let [NS {:noremap true :silent true}]
  (map [:x] :aa (bindf align.align_to_char 1 true) NS)
  (map [:x] :as (bindf align.align_to_char 2 true) NS))
