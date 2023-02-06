(module mods.util.telescope)

(let [telescope (require :telescope)
      actions (require :telescope.actions)
      builtin (require :telescope.builtin)
      which-key (require :which-key)]
  (telescope.setup {
    :defaults {
      :layout_strategy "vertical"
      :layout_config {
        :width 0.95
        :height 0.95
        :preview_height 0.68 }
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
              (let [gen (require :telescope.actions.generate)]
                (gen.refine buf {
                  :prompt_to_prefix true
                  :sorter false })))}}}}
    :extensions {
      :fzf {:fuzzy true :override_generic_sorter true :override_file_sorter true :case_mode "smart_case" }}})
  (telescope.load_extension "fzf")
  (which-key.register
    {
      :f {
        :name "find"
        :f [builtin.find_files "Find files"]
        :g [builtin.live_grep "Grep string"]
        :s [builtin.grep_string "Find string"]
        :z [(bindf builtin.grep_string {:shorten_path true :only_sort_text true :search ""}) "Fuzzy grep sring"]
        :b [builtin.buffers "Find buffers"]
        :c [builtin.command_history "Commands history"]
        :e [builtin.diagnostics "Diagnostics"]}
      :g {
        :r [builtin.lsp_references "LSP references"]
        :i [builtin.lsp_implementations "LSP implementations"]
        :c [builtin.git_commits "Commit history"]
        :s [builtin.git_status "Git status"]
        :S [builtin.git_stash "Git stashes"]}}))

