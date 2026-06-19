(module mods.tools.which-key {autoload {wk :which-key}})

;; Show which-key for common custom prefixes
(wk.setup
  {:triggers
    [ {:mode ["n" "v"] :prefix "<leader>"}
      {:mode ["n"] :prefix "f"}
      {:mode ["n"] :prefix "s"}
      {:mode ["n"] :prefix "t"}
      {:mode ["n"] :prefix "<space>"} ]})

(wk.add
  [{1 :s :group "split"}
   {1 :sd :desc "Decrease split width"}
   {1 :si :desc "Increase split width"}])
