(module mods.tools.telescope
  { autoload {
    telescope telescope
    utils telescope.utils
    builtin telescope.builtin
    actions telescope.actions
    themes telescope.themes
    generate telescope.actions.generate }})

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

(local lsp_theme
  (merge-table
    ivy_config
    {:show_line false
     :jump_type :never}))

(fn with-count [f opts?]
  (fn [args]
    (var opts (or opts? {}))
    (var back "")
    (for [i 1 vim.v.count]  ;; h v:count
      (set back (.. back "/..")))
    (var cwd (vim.fn.resolve (.. (utils.buffer_dir) back)))
    (f (merge-table
         (merge-table
           ivy_config
           {:cwd cwd
            :prompt_title (.. (. opts :prompt_title) " in " cwd)})
         args))))

(local themed_count_find_files
  (with-count builtin.find_files {:prompt_title "Find files"}))

(local themed_count_live_grep
  (with-count builtin.live_grep {:prompt_title "Grep string"}))

(map [:n] :fr (bindf builtin.resume {:initial_mode :normal})  {:desc "Resume last search"})
(map [:n] :ff themed_count_find_files                         {:desc "Find files"})
(map [:n] :fh (bindf themed_count_find_files {:hidden true})  {:desc "Find hidden files"})
(map [:n] :fg themed_count_live_grep                          {:desc "Grep string"})
(map [:n] :fs (bindf builtin.grep_string ivy_config)          {:desc "Find string"})
(map [:n] :fz (bindf builtin.grep_string fzf_opts_theme)      {:desc "Fuzzy grep string"})
(map [:n] :fb (bindf builtin.buffers ivy_config)              {:desc "Buffer list"})
(map [:n] :fc (bindf builtin.command_history ivy_config)      {:desc "Commands history"})
(map [:n] :gc (bindf builtin.git_commits ivy_config)          {:desc "Commit history"})
(map [:n] :gs (bindf builtin.git_status ivy_config)           {:desc "Git status"})
(map [:n] :gS (bindf builtin.git_stash ivy_config)            {:desc "Git stashes"})

(map [:n] :gi (bindf builtin.lsp_implementations lsp_theme)   {:desc "Implementations [LSP]"})
(map [:n] :gr (bindf builtin.lsp_references lsp_theme)        {:desc "References [LSP]"})
(map [:n] :fe (bindf builtin.diagnostics ivy_config)          {:desc "Diagnostics"})

