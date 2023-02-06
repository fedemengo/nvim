(module mods.ui.lualine {
  autoload {
    lualine lualine
    gps nvim-gps }})

(gps.setup {:depth 5})

(lualine.setup {
  :options {
    :icons_enabled true
    :theme "jellybeans"
    :component_separators { :left "" :right "" }
    :section_separators { :left ""  :right "" }
    :disabled_filetypes {}
    :always_divide_middle true
    :globalstatus false }
  :sections {
    :lualine_a ["mode"]
    :lualine_b ["branch"  "diff"]
    :lualine_c [
        "diagnostics"
        { :sources [ "nvim_diagnostic"  "vim_lsp" ]}
        { :sections [ "error" "warn" "info" "hint" ]}
        { :colored true }
        { :diagnostic_color { :error { :fg "#ff0000" } } }]
    :lualine_x [ gps.get_location {:cond gps.is_available }]
    :lualine_y ["filename"  "filetype"]
    :lualine_z ["progress" "location"]}
  :inactive_sections {
    :lualine_a []
    :lualine_b []
    :lualine_c ["filename"]
    :lualine_x []
    :lualine_y ["progress"]
    :lualine_z ["location"] }})

