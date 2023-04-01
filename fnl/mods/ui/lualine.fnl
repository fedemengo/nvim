(module mods.ui.lualine {
  autoload {
    lualine lualine
    gps nvim-gps }})

(gps.setup {:depth 5})

(fn session []
  (vim.fn.fnamemodify vim.v.this_session ":t"))

(lualine.setup {
  :options {
    :icons_enabled false
    :theme "material"
    :component_separators { :left "" :right "" }
    :section_separators { :left ""  :right "" }
    :disabled_filetypes {}
    :always_divide_middle true
    :globalstatus true }
  :sections {
    :lualine_a ["mode"]
    :lualine_b [
        "filename"
        "diagnostics" {
          :sources [ "nvim_diagnostic"  "vim_lsp" ]
          :sections [ "error" "warn" "info" "hint" ]
          :colored true
          :always_visible true }]
    :lualine_c [ gps.get_location {:cond gps.is_available }]
    :lualine_x ["branch"]
    :lualine_y ["filetype" session]
    :lualine_z ["progress" "location"]}})

