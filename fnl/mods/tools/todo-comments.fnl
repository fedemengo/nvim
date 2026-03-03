(module mods.tools.todo-comments
        {autoload {todo-comments :todo-comments
                   telescope telescope
                   themes telescope.themes}})

(todo-comments.setup {:highlight {:keyword :bg
                                  :after :fg}})

;; Use colored keywords only and dim the rest of the todo comment text.
(let [set-hl vim.api.nvim_set_hl
      keyword-fg {:FIX "#ff6188"
                  :HACK "#7fbbb3"
                  :NOTE "#78dce8"
                  :PERF "#a9dc76"
                  :TODO "#ffd866"
                  :TEST "#ab9df2"
                  :WARN "#fc9867"}
      comment-fg "#5c6370"
      apply-highlights
      (fn []
        (each [kind fg (pairs keyword-fg)]
          (set-hl 0 (.. :TodoBg kind) {:fg fg :bg :NONE :bold true})
          (set-hl 0 (.. :TodoFg kind) {:fg comment-fg :bg :NONE :italic true})
          (set-hl 0 (.. :TodoSign kind) {:fg fg :bg :NONE})))]
  (apply-highlights)
  (let [group (vim.api.nvim_create_augroup :todo-comments-highlights {:clear true})]
    (vim.api.nvim_create_autocmd :ColorScheme
                                 {:group group
                                  :callback apply-highlights})))

(fn todo-ivy-theme []
  (themes.get_ivy {:borderchars {:prompt ["─" "" "" "" "─" "─" "" ""]
                                 :results [""]
                                 :preview ["" "" "" "" "" "" "" ""]}
                   :shorten_path true
                   :layout_config {:height 0.7
                                   :preview_width 0.65}}))

(fn todo-telescope [opts]
  (telescope.load_extension :todo-comments)
  (let [todo-ext (. (. telescope :extensions) :todo-comments)]
    ((. todo-ext :todo) (merge-table (todo-ivy-theme)
                                     (or opts {})))))

(map [:n] :fC todo-telescope {:desc "Todo Telescope"})
