(module mods.tools.telescope
  { autoload {
    log "mods/dev/log"
    telescope telescope
    utils telescope.utils
    builtin telescope.builtin
    actions telescope.actions
    themes telescope.themes
    generate telescope.actions.generate }})

;;(log.setup {
;;            :outfile "/tmp/nvim.log"
;;            :color true
;;            :level "trace" })
;;
;;(log.trace "Loading telescope")

(telescope.setup {
  :defaults {
    :vimgrep_arguments [
      "rg"
      "--color=never"
      "--no-heading"
      "--with-filename"
      "--line-number"
      "--column"
      "--smart-case"
      "--only-matching" ]
    :layout_strategy "bottom_pane"
    :layout_config {
      :scroll_speed 8
      :preview_width 0.7 }
    :file_ignore_patterns [
      ".git/" "node_modules/" ".npm/" "*[Cc]ache/" "*-cache*"
      "*.tags*" "*.gemtags*" "*.csv" "*.tsv" "*.tmp*"
      "*.old" "*.plist" "*.jpg" "*.jpeg" "*.png"
      "*.tar.gz" "*.tar" "*.zip" "*.class" "*.pdb" "*.dll"
      "*.dat" "*.mca" "__pycache__" ".mozilla/" ".electron/"
      ".vpython-root/" ".gradle/" ".nuget/" ".cargo/"
      "yay/" ".local/share/Trash/"
      ".local/share/nvim/swap/" "code%-other/"]}
  :pickers {
    :live_grep {
      :mappings {
        :i {:<c-r> actions.to_fuzzy_refine }}}
    :find_files {
      :mappings {
        :i {
          :<c-r>
          (fn [buf]
              (generate.refine buf {
                :prompt_to_prefix true
                :sorter false }))}}}}
  :extensions {
    :fzf {:fuzzy true :override_generic_sorter true :override_file_sorter true :case_mode "smart_case" }}})

(telescope.load_extension "fzf")

(local fuzzy_search_opts {
  :shorten_path true
  :only_sort_text true
  :search ""
  :prompt_title "Fuzzy grep"})

(local ivy_config
  (themes.get_ivy {
    :borderchars {
      :prompt ["─" "" "" "" "─" "─" "" ""]
      :results [""]
      :preview ["" "" "" "" "" "" "" ""]}
    :preview_width 0.7
    :preview_title "" }))

(local fzf_opts_theme
  (merge-table
    ivy_config
    fuzzy_search_opts))

(local lsp_opts_theme
  (merge-table
    ivy_config
    {:show_line false
     :jump_type :never}))

(local diag_err_theme
  (merge-table
    ivy_config
    {:severity "error"
     :prompt_title "Workspace Errors"}))

(fn with-count [f opts?]
  (fn [args]
    (var opts (or opts? {}))
    (var back "")
    (for [i 1 vim.v.count]  ;; h v:count
      (set back (.. back "/..")))
    (var cwd (vim.fn.resolve (.. (utils.buffer_dir) back)))
    (var relwd (cwd:gsub (os.getenv :HOME) :$HOME))
    (f (merge-table
         (merge-table
           ivy_config
           {:cwd cwd
            :prompt_title (.. (. opts :prompt_title) " in " relwd)})
         args))))

(fn with-bufnr [f opts?]
  (fn []
    (f (merge-table
         opts?
         {:bufnr (vim.fn.bufnr)}))))

(local themed_count_find_files
  (with-count builtin.find_files {:prompt_title "Find files"}))

(local themed_count_live_grep
  (with-count builtin.live_grep {:prompt_title "Grep string"}))

(local themed_bufnr_lsp_impl
  (with-bufnr builtin.lsp_implementations lsp_opts_theme))

(local themed_bufnr_lsp_refs
  (with-bufnr builtin.lsp_references lsp_opts_theme))

(local themed_bufnr_lsp_defs
  (with-bufnr builtin.lsp_definitions lsp_opts_theme))

(map [:n] :fr (bindf builtin.resume {:initial_mode :normal})    {:desc "Resume last search"})
(map [:n] :ff themed_count_find_files                           {:desc "Find files"})
(map [:n] :fa (bindf themed_count_find_files {:hidden true})    {:desc "Find all files [hidden]"})
(map [:n] :fg themed_count_live_grep                            {:desc "Grep string"})

(map [:n] :<C-a> (bindf themed_count_find_files {:hidden true}) {:desc "Find all files [hidden]"})
(map [:n] :<C-f> themed_count_find_files                        {:desc "Find files"})

(map [:n] :fl (bindf builtin.lsp_document_symbols ivy_config)   {:desc "Find symbols [LSP]"})
(map [:n] :fs (bindf builtin.grep_string ivy_config)            {:desc "Find string"})
(map [:n] :fz (bindf builtin.grep_string fzf_opts_theme)        {:desc "Fuzzy grep string"})
(map [:n] :fb (bindf builtin.buffers ivy_config)                {:desc "Buffer list"})
(map [:n] :fc (bindf builtin.command_history ivy_config)        {:desc "Commands history"})
(map [:n] :gc (bindf builtin.git_commits ivy_config)            {:desc "Commit history"})
(map [:n] :gs (bindf builtin.git_status ivy_config)             {:desc "Git status"})
(map [:n] :gS (bindf builtin.git_stash ivy_config)              {:desc "Git stashes"})

(map [:n] :gi themed_bufnr_lsp_impl                             {:desc "Implementations [LSP]"})
(map [:n] :gr themed_bufnr_lsp_refs                             {:desc "References [LSP]"})
(map [:n] :gd themed_bufnr_lsp_defs                             {:desc "Definitions [LSP]"})
(map [:n] :fd (bindf builtin.diagnostics ivy_config)            {:desc "Diagnostics"})
(map [:n] :fe (bindf builtin.diagnostics diag_err_theme)        {:desc "Diagnostics [ERR]"})

(var pickers (require :telescope.pickers))
(var finders (require :telescope.finders))
(var make_entry (require :telescope.make_entry))
(var conf (. (require :telescope.config) :values))
(var state (require :telescope.actions.state))

(fn should_cd [old new]
  (var should (and
                (= 1 (vim.fn.isdirectory new))
                (not (= old new))))
  ;;(print (.. (tostring should)) " " new)
  should)


(fn extract_dir [path]
  (var dir (vim.fn.fnamemodify path ":h"))
  dir)

(fn extract_first_dir [path]
  (car (vim.split path :/)))

(fn join-with-sep [sep list]
  (if (= nil list)
    "<nil>"
    (if (= (length list) 0)
      ""
      (if (= (length list) 1)
        (car list)
        (.. (car list) sep (join-with-sep sep (cdr list)))))))


(fn get_find_cmd [default opts]
  ;;(print (. opts :hidden))
  (var cmd default)
  (when (. opts :hidden)
    (set cmd (cons default "--hidden")))
  cmd)

(var magic
  (fn [_opts]
    (var opts (or _opts {}))
    (var cwd (utils.buffer_dir))
    (var lcwd cwd)
    (tset opts :cwd cwd)
    ;;(tset opts :hidden (or (. opts :hidden) false))
    (tset opts :hidden true)
    (var fcmd ["rg" "--files" "--color" "never" "--follow"])
    (tset opts :entry_maker (or (. opts :entry_maker) (make_entry.gen_from_file opts)))
    (var p (pickers.new
      opts
      {:finder (finders.new_oneshot_job (get_find_cmd fcmd opts) opts)
       :previewer (conf.grep_previewer opts)
       :sorter (conf.file_sorter opts)
       :cache_picker false
       :attach_mappings (fn
                          [prompt_buf map]
                          (map
                            [:i :n]
                            :<C-h>
                            (fn []
                              (tset opts :hidden (not (. opts :hidden)))
                              (tset opts :entry_maker (make_entry.gen_from_file opts))
                              (p.refresh_previewer p)
                              (p.refresh
                                p
                                (finders.new_oneshot_job (get_find_cmd fcmd opts) opts)
                                {:reset_prompt false})))
                          (map
                            [:i :n]
                            :<C-e>
                            (fn []
                              (print "yolo")
                              (var picker (state.get_current_picker prompt_buf))
                              (var newdir (picker._get_prompt picker))
                              (var entry (state.get_selected_entry))
                              (var entry_dir ".")
                              (when (?. entry :value)
                                (set entry_dir (extract_first_dir (. entry :value))))
                              (when (= 0 (length newdir))
                                (set newdir entry_dir))
                              (set lcwd (vim.fn.resolve (.. lcwd "/" newdir)))
                              (when (should_cd (. opts :cwd) lcwd)
                                (tset opts :cwd lcwd)
                                (tset opts :entry_maker (make_entry.gen_from_file opts))
                                (p.refresh_previewer p)
                                (p.refresh
                                  p
                                  (finders.new_oneshot_job (get_find_cmd fcmd opts) opts)
                                  {:reset_prompt false}))))
                          (map
                            [:i :n]
                            :<tab>
                            (fn []
                              (var picker (state.get_current_picker prompt_buf))
                              (var newdir (picker._get_prompt picker))
                              (var entry (state.get_selected_entry))
                              (var entry_dir ".")
                              (when (?. entry :value)
                                (set entry_dir (extract_dir (. entry :value))))
                              (when (= 0 (length newdir))
                                (set newdir entry_dir))
                              (set lcwd (vim.fn.resolve (.. lcwd "/" newdir)))
                              (when (should_cd (. opts :cwd) lcwd)
                                (tset opts :cwd lcwd)
                                (tset opts :entry_maker (make_entry.gen_from_file opts))
                                (p.refresh_previewer p)
                                (p.refresh
                                  p
                                  (finders.new_oneshot_job (get_find_cmd fcmd opts) opts)
                                  {:reset_prompt true}))))
                          (map
                            [:i :n]
                            :<S-tab>
                            (fn []
                              (when (not (= lcwd :/))
                                (set lcwd (vim.fn.resolve (.. lcwd "/.."))))
                              ;;(print lcwd)
                              (tset opts :cwd lcwd)
                              (tset opts :entry_maker (make_entry.gen_from_file opts))
                              (p.refresh_previewer p)
                              (p.refresh
                                p
                                (finders.new_oneshot_job (get_find_cmd fcmd opts) opts)
                                {:reset_prompt true})))
                          true)}))
    (p.find p)))

(local themed_magic
  (bindf magic ivy_config))

(map [:n] :fj themed_magic            {:desc "Find and move around"})

