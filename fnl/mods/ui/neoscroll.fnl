(module mods.ui.neoscroll {
  autoload {
    ns neoscroll
    config neoscroll.config }})

(ns.setup)

(config.set_mappings {
  :<C-u> ["scroll" ["-vim.wo.scroll" "true" "250"]]
  :<C-d> ["scroll" [ "vim.wo.scroll" "true" "250"]]
  :<C-y> ["scroll" ["-0.10" "false" "100"]]
  :<C-e> ["scroll" [ "0.10" "false" "100"]]})

