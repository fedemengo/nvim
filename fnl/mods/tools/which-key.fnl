(module mods.tools.which-key {autoload {wk :which-key}})

;; Show which-key for <leader>, and keep custom prefixes for 'f' and 't'
(wk.setup
  {:triggers
    [ {:mode ["n" "v"] :prefix "<leader>"}
      {:mode ["n"] :prefix "f"}
      {:mode ["n"] :prefix "t"} ]})
