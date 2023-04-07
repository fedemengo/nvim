(module mods.tools.treesitter {
  autoload {
    conf nvim-treesitter.configs }})

(conf.setup {
  :ensure_installed ["go" "cpp" "python" "vim" "bash" "lua" "yaml" "dockerfile" "fennel" "json"]
  :sync_install false
  :indent {:enable true }
  :highlight {:enable true :additional_vim_regex_highlighting false }})

