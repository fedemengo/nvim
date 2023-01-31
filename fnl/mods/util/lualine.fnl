(module mods.util.lualine)

(let [lualine (require :lualine)]
  (lualine.setup {
    :options {
      :icons_enabled true
      :theme "ayu_mirage"
      :component_separators { :left "" :right ""}
      :section_separators { :left ""  :right ""}
      :disabled_filetypes {}
      :always_divide_middle true
      :globalstatus false
    }
    :sections {
      :lualine_a ["mode"]
      :lualine_b ["branch"  "diff"]
      :lualine_c [
          "diagnostics"
          { :sources [ "nvim_diagnostic"  "vim_lsp" ]}
          { :colored true }
          { :diagnostic_color { :error { :fg "#ff0000" } } }
      ]
      :lualine_x ["filename"  "filetype"]
      :lualine_y ["progress"]
      :lualine_z ["location"]
    }
    :inactive_sections {
      :lualine_a []
      :lualine_b []
      :lualine_c ["filename"]
      :lualine_x []
      :lualine_y ["progress"]
      :lualine_z ["location"]
    }
  })
)
