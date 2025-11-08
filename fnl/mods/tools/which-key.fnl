(module mods.tools.which-key {autoload {wk :which-key}})

(wk.setup
  {:triggers
    [ {:mode ["n"] 1 "f"}
      {:mode ["n"] 1 "t"} ]})

