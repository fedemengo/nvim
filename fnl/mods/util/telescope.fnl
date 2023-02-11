(module mods.util.telescope
  { autoload {
    telescope telescope
    builtin telescope.builtin
    actions telescope.actions
    themes telescope.themes
    generate telescope.actions.generate }})

(telescope.setup {
  :defaults {
    :layout_strategy "bottom_pane"
    :layout_config {
      :preview_width 0.7
      :width 30
      :height 50 }
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
    :preview_width 0.65 }))

(local fzf_conf_with_theme (merge-table ivy_config fuzzy_search_opt))

(map ["n"] "ff" (bindf builtin.find_files ivy_config)           {:desc "Find files"})
(map ["n"] "fg" (bindf builtin.live_grep ivy_config)            {:desc "Grep string"})
(map ["n"] "fs" (bindf builtin.grep_string ivy_config)          {:desc "Find string"})
(map ["n"] "fz" (bindf builtin.grep_string fzf_conf_with_theme) {:desc "Fuzzy grep string"})
(map ["n"] "fb" (bindf builtin.buffers ivy_config)              {:desc "Buffer list"})
(map ["n"] "fc" (bindf builtin.command_history ivy_config)      {:desc "Commands history"})
(map ["n"] "gc" (bindf builtin.git_commits ivy_config)          {:desc "Commit history"})
(map ["n"] "gs" (bindf builtin.git_status ivy_config)           {:desc "Git status"})
(map ["n"] "gS" (bindf builtin.git_stash ivy_config)            {:desc "Git stashes"})

(map ["n"] "gi" (bindf builtin.lsp_implementations ivy_config)  {:desc "Implementations [LSP]"})
(map ["n"] "gr" (bindf builtin.lsp_references ivy_config)       {:desc "References [LSP]"})
(map ["n"] "fe" (bindf builtin.diagnostics ivy_config)          {:desc "Diagnostics"})

