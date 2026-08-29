(module mods.ui.lualine {autoload {lualine :lualine
                                   navic :nvim-navic}})

(navic.setup {:depth_limit 5})

(fn session []
  (vim.fn.fnamemodify vim.v.this_session ":t"))

(fn location []
  (navic.get_location))

;; minova: flat statusline to match the tmux theme — one transparent
;; background, fg-only colors, no powerline blocks
(local colors {:dim "#7f7f7f"
               :bright "#ffffff"
               :orange "#ff6526"
               :magenta "#ff55ff"
               :green "#50fa7b"})

(local mode-style {:fg colors.orange :bg :NONE :gui :bold})
(local text-style {:fg colors.dim :bg :NONE})
(local flat-mode {:a mode-style :b text-style :c text-style})
(local minova {:normal flat-mode
               :insert flat-mode
               :visual flat-mode
               :replace flat-mode
               :command flat-mode
               :terminal flat-mode
               :inactive flat-mode})

(lualine.setup {:options {:icons_enabled false
                          :theme minova
                          :component_separators {:left "•" :right "•"}
                          :section_separators {:left "" :right ""}
                          :disabled_filetypes {}
                          :always_divide_middle true
                          :globalstatus true}
                :sections {:lualine_a [:mode]
                           :lualine_b [{1 :filename
                                        :color {:fg colors.bright :gui :bold}}
                                       :diagnostics
                                       {:sources [:nvim_diagnostic :vim_lsp]
                                        :sections [:error :warn :info :hint]
                                        :colored true
                                        :always_visible true}]
                           :lualine_c [location {:cond navic.is_available}]
                           :lualine_x [{1 :branch
                                        :color {:fg colors.magenta}}]
                           :lualine_y [:filetype
                                       {1 session
                                        :color {:fg colors.green}}
                                       :lsp_progress]
                           :lualine_z [:progress :location]}})
