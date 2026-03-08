(module mods.tools.telescope
        {autoload {log :mods/dev/log
                   telescope telescope
                   utils telescope.utils
                   builtin telescope.builtin
                   actions telescope.actions
                   themes telescope.themes
                   generate telescope.actions.generate}})

;;(log.setup {
;;            :outfile "/tmp/nvim.log"
;;            :color true
;;            :level "trace" })
;;
;;(log.trace "Loading telescope")

(local media-filetypes [:png :webp :jpg :jpeg :gif :mp4 :webm :pdf :epub])
(local media-find-cmd :rg)

(telescope.setup {:defaults {:vimgrep_arguments [:rg
                                                 :--color=never
                                                 :--no-heading
                                                 :--with-filename
                                                 :--line-number
                                                 :--column
                                                 :--smart-case
                                                 :--only-matching]
                             :mappings {:i {:<C-n> actions.select_tab}
                                        :n {:<C-n> actions.select_tab}}
                             :layout_strategy :bottom_pane
                             :layout_config {:scroll_speed 8
                                             :bottom_pane {:preview_width 0.7}}
                             :file_ignore_patterns [:.git/
                                                    :node_modules/
                                                    :.npm/
                                                    :*.tags*
                                                    :*.gemtags*
                                                    :*.csv
                                                    :*.tsv
                                                    :*.tmp*
                                                    :*.old
                                                    :*.plist
                                                    :*.jpg
                                                    :*.jpeg
                                                    :*.png
                                                    :*.tar.gz
                                                    :*.tar
                                                    :*.zip
                                                    :*.class
                                                    :*.pdb
                                                    :*.dll
                                                    :*.dat
                                                    :*.mca
                                                    :__pycache__
                                                    :.mozilla/
                                                    :.electron/
                                                    :.vpython-root/
                                                    :.gradle/
                                                    :.nuget/
                                                    :.cargo/
                                                    :yay/
                                                    :.local/share/Trash/
                                                    :.local/share/nvim/swap/
                                                    "code%-other/"]}
                  :pickers {:colorscheme {:enable_preview true}
                            :live_grep {:mappings {:i {:<c-r> actions.to_fuzzy_refine}}}
                            :find_files {:mappings {:i {:<c-r> (fn [buf]
                                                                 (generate.refine buf
                                                                                  {:prompt_to_prefix true
                                                                                   :sorter false}))}}}}
                  :extensions {:fzf {:fuzzy true
                                     :override_generic_sorter true
                                     :override_file_sorter true
                                     :case_mode :smart_case}
                               :media_files {:filetypes media-filetypes
                                             :find_cmd media-find-cmd}}})

(telescope.load_extension :fzf)
(telescope.load_extension :make)
(telescope.load_extension :media_files)

(local fuzzy_search_opts {:shorten_path true
                          :only_sort_text true
                          :search ""
                          :prompt_title "Fuzzy grep"})

(fn gen_ivy_config [height]
  (themes.get_ivy {:borderchars {:prompt ["─" "" "" "" "─" "─" "" ""]
                                 :results [""]
                                 :preview ["" "" "" "" "" "" "" ""]}
                   :shorten_path true
                   :layout_config {: height :preview_width 0.7}}))

;:preview_title ""}))

(local ivy_config (gen_ivy_config 0.7))

(local fzf_opts_theme (merge-table ivy_config fuzzy_search_opts))

(local lsp_opts_theme
       (merge-table ivy_config {:show_line false :jump_type :never}))

(local diag_err_theme
       (merge-table ivy_config
                    {:severity :error :prompt_title "Workspace Errors"}))

(fn with-count [f opts?]
  (fn [args]
    (var opts (or opts? {}))
    (var back "")
    (for [i 1 vim.v.count] ;; h v:count
      (set back (.. back "/..")))
    (var cwd (vim.fn.resolve (.. (utils.buffer_dir) back)))
    (var relwd (cwd:gsub (os.getenv :HOME) :$HOME))
    (f (merge-table (merge-table ivy_config
                                 {: cwd
                                  :prompt_title (.. (. opts :prompt_title)
                                                    " in " relwd)})
                    args))))

(fn with-bufnr [f opts?]
  (fn []
    (f (merge-table opts? {:bufnr (vim.fn.bufnr)}))))

(local themed_count_find_files
       (with-count builtin.find_files {:prompt_title "Find files"}))

(local themed_count_live_grep
       (with-count builtin.live_grep {:prompt_title "Grep string"}))

(local themed_bufnr_lsp_impl (with-bufnr builtin.lsp_implementations
                               lsp_opts_theme))

(local themed_bufnr_lsp_refs (with-bufnr builtin.lsp_references lsp_opts_theme))

(local themed_bufnr_lsp_defs
       (with-bufnr builtin.lsp_definitions lsp_opts_theme))

(fn media-files []
  (let [media-ext (. (. telescope :extensions) :media_files)]
    ((. media-ext :media_files) ivy_config)))

(map [:n] :fr (bindf builtin.resume {:initial_mode :normal})
     {:desc "Resume last search"})

(map [:n] :fa (bindf themed_count_find_files {:hidden true})
     {:desc "Find all files [hidden]"})

(map [:n] :fg themed_count_live_grep {:desc "Grep string"})
(map [:n] :fm media-files {:desc "Find media files"})

(map [:n] :<C-h> (bindf themed_count_find_files {:hidden true})
     {:desc "Find all files [hidden]"})

(map [:n] :fl (bindf builtin.lsp_document_symbols ivy_config)
     {:desc "Find symbols [LSP]"})

(map [:n] :fz (bindf builtin.grep_string fzf_opts_theme)
     {:desc "Fuzzy grep string"})

(map [:n] :fb (bindf builtin.buffers ivy_config) {:desc "Buffer list"})
(map [:n] :fc (bindf builtin.command_history ivy_config)
     {:desc "Commands history"})

(map [:n] :gc (bindf builtin.git_commits ivy_config) {:desc "Commit history"})
(map [:n] :gs (bindf builtin.git_status ivy_config) {:desc "Git status"})
(map [:n] :gS (bindf builtin.git_stash ivy_config) {:desc "Git stashes"})

(map [:n] :gi themed_bufnr_lsp_impl {:desc "Implementations [LSP]"})
(map [:n] :gr themed_bufnr_lsp_refs {:desc "References [LSP]"})
(map [:n] :gd themed_bufnr_lsp_defs {:desc "Definitions [LSP]"})
(map [:n] :fd (bindf builtin.diagnostics
                     (merge-table {:sort_by :severity :line_width 10}
                                  (deep-copy ivy_config)))
     {:desc :Diagnostics})

(fn diagnostics-opts []
  {:sort_by :severity
   :severity :error
   :line_width 10
   :path_display {:shorten 3}
   :dynamic_preview_title true
   :prompt_title "Workspace Errors"})

(map [:n] :fe (bindf builtin.diagnostics
                     (merge-table (diagnostics-opts) ivy_config))
     {:desc "Diagnostics [ERR]"})

(var pickers (require :telescope.pickers))
(var finders (require :telescope.finders))
(var make_entry (require :telescope.make_entry))
(var previewers (require :telescope.previewers))
(var conf (. (require :telescope.config) :values))
(var state (require :telescope.actions.state))
(local media-preview-script
       (.. (vim.fn.stdpath :data)
           :/lazy/telescope-media-files.nvim/scripts/vimg))

(fn should_cd [old new]
  "Check if we should change directory"
  (and (= 1 (vim.fn.isdirectory new)) ;; new is an existing directory
       ;; old and new are not the same
       (not (= old new))))

(fn extract_dirs [path]
  (vim.fn.fnamemodify path ":h"))

(fn extract_first_dir [path]
  (var clean (path:gsub "%./" ""))
  ;; http://www.lua.org/pil/20.2.html#:~:text=character%20%60%25%C2%B4%20works%20as%20an%20escape
  (car (vim.split clean "/")))

(fn dirs_from_entry [curr_dir dir_extractor]
  "Extract the directory from the selected entry in the current picker"
  (var entry (state.get_selected_entry))
  (var new_dir "")
  ;; In grep mode entry.value = "file:lnum:col:text"; use entry.filename for the clean path
  (var path (or (?. entry :filename) (?. entry :value)))
  (when path
    ;; Strip curr_dir prefix so extractors work on relative paths
    (var rel_path (if (vim.startswith path curr_dir)
                      (string.sub path (+ (length curr_dir) 2))
                      path))
    (set new_dir (dir_extractor rel_path)))
  (var full_path (vim.fn.resolve (.. curr_dir "/" new_dir)))
  (full_path:gsub "//" "/"))

(fn first_dir_from_entry [curr_dir]
  (dirs_from_entry curr_dir extract_first_dir))

(fn all_dirs_from_entry [curr_dir]
  (dirs_from_entry curr_dir extract_dirs))

(fn media-file? [entry]
  (let [path (or (. entry :path) (. entry :filename) (. entry :value) "")
        ext (string.lower (vim.fn.fnamemodify path ":e"))]
    (vim.tbl_contains media-filetypes ext)))

(fn media-previewer-command [cwd entry status]
  (let [path (or (. entry :path) (. entry :filename) (. entry :value))]
    (when path
      (let [preview-winid (. (. status.layout :preview) :winid)
            (row col) (unpack (vim.api.nvim_win_get_position preview-winid))
            width (vim.api.nvim_win_get_width preview-winid)
            height (vim.api.nvim_win_get_height preview-winid)
            full-path (if (= "/" (string.sub path 1 1))
                          path
                          (.. cwd "/" path))]
        [media-preview-script full-path col (+ row 1) width height 250]))))

(fn magic-previewer [opts]
  (let [file-previewer (conf.file_previewer opts)
        media-previewer (previewers.new_termopen_previewer {:get_command (fn [entry
                                                                              status]
                                                                           (media-previewer-command (. opts
                                                                                                       :cwd)
                                                                                                    entry
                                                                                                    status))})]
    (previewers.new {:setup (fn []
                              {:active :file})
                     :teardown (fn [self]
                                 ((. file-previewer :teardown) file-previewer)
                                 ((. media-previewer :teardown) media-previewer))
                     :send_input (fn [self input]
                                   (if (= :media (. self.state :active))
                                       ((. media-previewer :send_input) media-previewer
                                                                        input)
                                       ((. file-previewer :send_input) file-previewer
                                                                       input)))
                     :scroll_fn (fn [self direction]
                                  (if (= :media (. self.state :active))
                                      ((. media-previewer :scroll_fn) media-previewer
                                                                      direction)
                                      ((. file-previewer :scroll_fn) file-previewer
                                                                     direction)))
                     :scroll_horizontal_fn (fn [self direction]
                                             (if (= :media
                                                    (. self.state :active))
                                                 ((. media-previewer
                                                     :scroll_horizontal_fn) media-previewer
                                                                                                                                                 direction)
                                                 ((. file-previewer
                                                     :scroll_horizontal_fn) file-previewer
                                                                                                                                                direction)))
                     :preview_fn (fn [self entry status]
                                   (if (media-file? entry)
                                       (do
                                         (tset self.state :active :media)
                                         ((. media-previewer :preview) media-previewer
                                                                       entry
                                                                       status))
                                       (do
                                         (tset self.state :active :file)
                                         ((. file-previewer :preview) file-previewer
                                                                      entry
                                                                      status))))})))

(fn new_magic_finder [opts]
  "Create a new finder job for the magic picker"
  (var fcmd [:fd :--type :f :--color :never :--follow :--max-results :5000])
  (set fcmd (cons fcmd [:--max-depth (. opts :fcmd_depth)]))
  (when (. opts :hidden)
    (set fcmd (cons fcmd :--hidden)))
  (finders.new_oneshot_job fcmd opts))

(fn new_magic_grepper [opts]
  "Create a live grep finder job for the magic picker"
  (var gcmd [:rg
             :--color=never
             :--no-heading
             :--with-filename
             :--line-number
             :--column
             :--smart-case
             :--max-depth
             (. opts :fcmd_depth)])
  (when (. opts :hidden)
    (set gcmd (cons gcmd :--hidden)))
  (finders.new_job (fn [query]
                     (when (and query (not= query ""))
                       (cons gcmd [query "--" (. opts :cwd)])))
                   (make_entry.gen_from_vimgrep opts) nil (. opts :cwd)))

(fn update_magic_prompt_title [opts]
  (var mode (if (= (. opts :mode) :grep) :grep :find))
  (var cwd (. opts :cwd))
  (var relcwd (cwd:gsub (os.getenv :HOME) :$HOME))
  (var hidden? (if (. opts :hidden) :on :off))
  (tset opts :prompt_title
        (.. mode
            " [d:"
            (. opts :fcmd_depth)
            "] [h:"
            hidden?
            "] "
            relcwd)))

(fn refresh [picker opts popts]
  "Refresh the picker with new options"
  (tset opts :entry_maker
        (if (= (. opts :mode) :grep)
            (make_entry.gen_from_vimgrep opts)
            (make_entry.gen_from_file opts)))
  (update_magic_prompt_title opts)
  (when (and picker.prompt_border picker.prompt_border.change_title)
    (picker.prompt_border:change_title (. opts :prompt_title)))
  (picker.refresh_previewer picker)
  (var finder (if (= (. opts :mode) :grep)
                  (new_magic_grepper opts)
                  (new_magic_finder opts)))
  (picker.refresh picker finder popts))

(var magic (fn [_opts]
             (var opts (deep-copy (or _opts {})))
             (var cwd (utils.buffer_dir))
             (tset opts :fcmd_depth 4)
             (tset opts :cwd cwd)
             (tset opts :mode (or (. opts :mode) :files))
             (tset opts :entry_maker
                   (if (= (. opts :mode) :grep)
                       (make_entry.gen_from_vimgrep opts)
                       (make_entry.gen_from_file opts)))
             (update_magic_prompt_title opts)
             (var p
                  (pickers.new opts
                               {:finder (if (= (. opts :mode) :grep)
                                            (new_magic_grepper opts)
                                            (new_magic_finder opts))
                                :previewer (magic-previewer opts)
                                :sorter (conf.file_sorter opts)
                                :cache_picker false
                                :attach_mappings (fn [buf map]
                                                   (map [:n] :S
                                                        (fn []
                                                          ;; decrease search depth
                                                          (when (> (. opts
                                                                      :fcmd_depth)
                                                                   1)
                                                            (tset opts
                                                                  :fcmd_depth
                                                                  (- (. opts
                                                                        :fcmd_depth)
                                                                     1))
                                                            (refresh p opts
                                                                     {:reset_prompt false}))))
                                                   (map [:n] :D
                                                        (fn []
                                                          ;; increase search depth
                                                          (tset opts
                                                                :fcmd_depth
                                                                (+ (. opts
                                                                      :fcmd_depth)
                                                                   1))
                                                          (refresh p opts
                                                                   {:reset_prompt false})))
                                                   (map [:i :n] :<C-h>
                                                        (fn []
                                                          (tset opts :hidden
                                                                (not (. opts
                                                                        :hidden)))
                                                          (refresh p opts
                                                                   {:reset_prompt false})))
                                                   (map [:i :n] :<C-e>
                                                        (fn []
                                                          (var nwd
                                                               (first_dir_from_entry cwd))
                                                          (when (should_cd (. opts
                                                                              :cwd)
                                                                           nwd)
                                                            (set cwd nwd)
                                                            (tset opts :cwd cwd)
                                                            (refresh p opts
                                                                     {:reset_prompt false}))))
                                                   (map [:i :n] :<tab>
                                                        (fn []
                                                          (var nwd
                                                               (all_dirs_from_entry cwd))
                                                          (when (should_cd cwd
                                                                           nwd)
                                                            (set cwd nwd)
                                                            (tset opts :cwd cwd)
                                                            (refresh p opts
                                                                     {:reset_prompt true}))))
                                                   (map [:i :n] :<S-tab>
                                                        (fn []
                                                          (when (not (= cwd "/"))
                                                            (set cwd
                                                                 (vim.fn.resolve (.. cwd
                                                                                     "/..")))
                                                            (tset opts :cwd cwd)
                                                            (refresh p opts
                                                                     {:reset_prompt false}))))
                                                   (map [:i :n] :<C-g>
                                                        (fn []
                                                          (tset opts :mode
                                                                (if (= (. opts
                                                                          :mode)
                                                                       :grep)
                                                                    :files
                                                                    :grep))
                                                          (if (= (. opts :mode)
                                                                 :grep)
                                                              (tset opts
                                                                    :entry_maker
                                                                    (make_entry.gen_from_vimgrep opts))
                                                              (tset opts
                                                                    :entry_maker
                                                                    (make_entry.gen_from_file opts)))
                                                          (refresh p opts
                                                                   {:reset_prompt false})))
                                                   true)}))
             (p.find p)))

(fn themed_magic_height [height]
  (bindf magic (gen_ivy_config height)))
(local themed_magic (bindf magic ivy_config))

(fn count_themed_magic []
  (let [n (. vim.v :count)
        n (if (> n 0) n 4)
        n (math.max 1 (math.min n 9))
        height (/ n 10)]
    ((themed_magic_height height))))

(fn magic-grep-cword []
  (magic (merge-table ivy_config
                      {:mode :grep :default_text (vim.fn.expand :<cword>)})))

(fn magic-grep-visual []
  (vim.cmd "noau normal! \"vy")
  (var text (vim.fn.getreg :v))
  (vim.fn.setreg :v [])
  (magic (merge-table ivy_config {:mode :grep :default_text text})))

(map [:n] :F count_themed_magic {:desc "Find and move around [count height]"})
(map [:n] :<C-f> themed_magic {:desc "Find and move around"})
(map [:n] :fs magic-grep-cword {:desc "Find string [magic grep]"})
(map [:v] :fs magic-grep-visual {:desc "Find selection [magic grep]"})
