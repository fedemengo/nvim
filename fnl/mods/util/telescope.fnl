(module mods.util.telescope)

(let [telescope (require :telescope)
      actions (require :telescope.actions)]
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
  (telescope.load_extension "fzf"))

