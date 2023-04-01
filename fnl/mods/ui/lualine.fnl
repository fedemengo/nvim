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
    :lualine_b [
        "filename"
        "diagnostics"
        { :sources [ "nvim_diagnostic"  "vim_lsp" ]}
        { :sections [ "error" "warn" "info" "hint" ]}
        { :colored true }
        { :diagnostic_color { :error { :fg "#ff0000" } } }]
    :lualine_c [ gps.get_location {:cond gps.is_available }]
    :lualine_x ["branch"  "diff"]
    :lualine_y ["filetype"]
    :lualine_z ["progress" "location"]}})

