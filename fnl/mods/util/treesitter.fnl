(module mods.util.treesitter)


(let [treesitter (require :nvim-treesitter.configs)]
  (treesitter.setup
    {
      :ensure_installed ["go" "cpp" "python" "vim" "bash" "lua" "yaml" "dockerfile" "fennel"]
      :sync_install false
      :indent {:enable true }
      :highlight {:enable true :additional_vim_regex_highlighting false }
    }
  )
)
