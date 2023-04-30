(module mods.tools.treesitter {
  autoload {
    conf nvim-treesitter.configs }})

(fn is-large-file [_ bufnr]
  (or
    (> (vim.fn.getfsize (vim.fn.bufname bufnr)) (* 1024 1024)) ; 1MB is rarely source code
    (> (vim.api.nvim_buf_line_count bufnr) 5_000)))

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
  :indent {
    :enable true
    :disable is-large-file }
  :highlight {
    :enable true
    :disable is-large-file
    :additional_vim_regex_highlighting false }})

