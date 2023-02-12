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

(local fuzzy_search_opt {
  :shorten_path true
  :only_sort_text true
  :search ""
  :prompt_title "Fuzzy grep"})

(local ivy_config
  (themes.get_ivy {
    :borderchars {
      :prompt ["" "" "" "" "" "" "" ""]
      :results [""]
      :preview ["" "" "" "│" "" "" "" ""]}
    :preview_width 0.7 }))

(local fzf_conf_with_theme (merge-table ivy_config fuzzy_search_opt))

(fn with-count [f prompt]
  (fn [args]
    (var back "")
    (for [i 1 vim.v.count]  ;; h v:count
      (set back (.. back "/..")))
    (var cwd (vim.fn.resolve (.. (utils.buffer_dir) back)))
    (f (merge-table (merge-table ivy_config {:cwd cwd :prompt_title (.. prompt " in " cwd)}) args))))

(map [:n] :fr (bindf builtin.resume {:initial_mode :normal})                        {:desc "Resume last search"})
(map [:n] :ff (with-count builtin.find_files "Find files")                          {:desc "Find files"})
(map [:n] :fh (bindf (with-count builtin.find_files "Find files") {:hidden true})   {:desc "Find hidden files"})
(map [:n] :fg (with-count builtin.live_grep "Grep string")                          {:desc "Grep string"})
(map [:n] :fs (bindf builtin.grep_string ivy_config)                                {:desc "Find string"})
(map [:n] :fz (bindf builtin.grep_string fzf_conf_with_theme)                       {:desc "Fuzzy grep string"})
(map [:n] :fb (bindf builtin.buffers ivy_config)                                    {:desc "Buffer list"})
(map [:n] :fc (bindf builtin.command_history ivy_config)                            {:desc "Commands history"})
(map [:n] :gc (bindf builtin.git_commits ivy_config)                                {:desc "Commit history"})
(map [:n] :gs (bindf builtin.git_status ivy_config)                                 {:desc "Git status"})
(map [:n] :gS (bindf builtin.git_stash ivy_config)                                  {:desc "Git stashes"})

(map [:n] :gi (bindf builtin.lsp_implementations ivy_config)                        {:desc "Implementations [LSP]"})
(map [:n] :gr (bindf builtin.lsp_references ivy_config)                             {:desc "References [LSP]"})
(map [:n] :fe (bindf builtin.diagnostics ivy_config)                                {:desc "Diagnostics"})

