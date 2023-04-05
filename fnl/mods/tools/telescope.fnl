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
  "Check if we should change directory"
  (and
    (= 1 (vim.fn.isdirectory new)) ;; new is an existing directory
    (not (= old new)))) ;; old and new are not the same

(fn extract_dirs [path]
  (vim.fn.fnamemodify path ":h"))

(fn extract_first_dir [path]
  (set clean (path:gsub "%./" ""))  ;; http://www.lua.org/pil/20.2.html#:~:text=character%20%60%25%C2%B4%20works%20as%20an%20escape
  (car (vim.split clean :/)))

(fn dirs_from_entry [curr_dir dir_extractor]
  "Extract the directory from the selected entry in the current picker"
  (var entry (state.get_selected_entry))
  (var new_dir "")
  (when (?. entry :value)
    (set new_dir (dir_extractor (. entry :value))))
  (var full_path (vim.fn.resolve (.. curr_dir "/" new_dir)))
  (full_path:gsub "//" "/"))

(fn first_dir_from_entry [curr_dir]
  (dirs_from_entry curr_dir extract_first_dir))

(fn all_dirs_from_entry [curr_dir]
  (dirs_from_entry curr_dir extract_dirs))

(fn new_magic_finder_job [opts]
  "Create a new finder job for the magic picker"
  (var fcmd ["fd" "--type" "f" "--color" "never" "--follow" "--max-results" "5000"])
  (set fcmd (cons fcmd ["--max-depth" (. opts :fcmd_depth)]))
  (when (. opts :hidden)
    (set fcmd (cons fcmd "--hidden")))
  (finders.new_oneshot_job fcmd opts))

(fn refresh [picker opts popts]
  "Refresh the picker with new options"
  (picker.refresh_previewer picker)
  (picker.refresh
    picker
    (new_magic_finder_job opts)
    popts))

(var magic
  (fn [_opts]
    (var opts (deep-copy (or _opts {})))
    (var cwd (utils.buffer_dir))
    (tset opts :fcmd_depth 4)
    (tset opts :cwd cwd)
    (tset opts :entry_maker (make_entry.gen_from_file opts))
    (tset opts :prompt_title (.. "Magic in " (. opts :cwd)))
    (var p (pickers.new
      opts
      {:finder (new_magic_finder_job opts)
       :previewer (conf.grep_previewer opts)
       :sorter (conf.file_sorter opts)
       :cache_picker false
       :attach_mappings (fn [_ map]
                          (map
                            [:n]
                            :S
                            (fn []
                              (when (> (. opts :fcmd_depth) 1)
                                (tset opts :fcmd_depth (- (. opts :fcmd_depth) 1))
                                (print (.. "search in " (. opts :cwd) " @ depth " (. opts :fcmd_depth)))
                                (refresh p opts {:reset_prompt false}))))
                          (map
                            [:n]
                            :D
                            (fn []
                              (tset opts :fcmd_depth (+ (. opts :fcmd_depth) 1))
                              (print (.. "search in " (. opts :cwd) " @ depth " (. opts :fcmd_depth)))
                              (refresh p opts {:reset_prompt false})))
                          (map
                            [:i :n]
                            :<C-h>
                            (fn []
                              (tset opts :hidden (not (. opts :hidden)))
                              (tset opts :entry_maker (make_entry.gen_from_file opts))
                              (refresh p opts {:reset_prompt false})))
                          (map
                            [:i :n]
                            :<C-e>
                            (fn []
                              (var nwd (first_dir_from_entry cwd))
                              (when (should_cd (. opts :cwd) nwd)
                                (set cwd nwd)
                                (tset opts :cwd cwd)
                                (tset opts :entry_maker (make_entry.gen_from_file opts))
                                (print (.. "search in " (. opts :cwd) " @ depth " (. opts :fcmd_depth)))
                                (refresh p opts {:reset_prompt false}))))
                          (map
                            [:i :n]
                            :<tab>
                            (fn []
                              (var nwd (all_dirs_from_entry cwd))
                              (when (should_cd cwd nwd)
                                (set cwd nwd)
                                (tset opts :cwd cwd)
                                (tset opts :entry_maker (make_entry.gen_from_file opts))
                                (print (.. "search in " (. opts :cwd) " @ depth " (. opts :fcmd_depth)))
                                (refresh p opts {:reset_prompt true :prompt_title (.. "Magic in " (. opts :cwd)) }))))
                          (map
                            [:i :n]
                            :<S-tab>
                            (fn []
                              (when (not (= cwd "/"))
                                (set cwd (vim.fn.resolve (.. cwd "/..")))
                                (tset opts :cwd cwd)
                                (tset opts :entry_maker (make_entry.gen_from_file opts))
                                (print (.. "search in " (. opts :cwd) " @ depth " (. opts :fcmd_depth)))
                                (refresh p opts {:reset_prompt false}))))
                          true)}))
    (p.find p)))

(local themed_magic
  (bindf magic ivy_config))

(map [:n] :<Tab>      themed_magic  {:desc "Find and move around"})
(map [:n] :fj         themed_magic  {:desc "Find and move around"})
(map [:n] :<C-space>  themed_magic  {:desc "Find and move around"})

