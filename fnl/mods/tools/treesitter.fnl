(module mods.tools.treesitter {
  autoload {
    conf nvim-treesitter.configs }})

(conf.setup {
  :ensure_installed [
    "commonlisp" "fennel"
    "go" "gosum" "gomod"
    "cpp"
    "python"
    "lua"
    "vim"
    "bash"
    "gitcommit" "gitignore"
    "make"
    "diff"
    "dockerfile"
    "yaml" "json"]
  :sync_install false
  :indent {:enable true }
  :highlight {:enable true :additional_vim_regex_highlighting false }})

