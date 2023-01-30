(module mods.util.telescope)

(let [telescope (require :telescope)]
  (telescope.setup
    {
      :defaults {
        :layout_strategy "vertical"
        :layout_config {
          :width 0.95
          :height 0.95
          :preview_height 0.68
        }
        :file_ignore_patterns [
          ".git/" "node_modules/" ".npm/" "*[Cc]ache/" "*-cache*"
          "*.tags*" "*.gemtags*" "*.csv" "*.tsv" "*.tmp*"
          "*.old" "*.plist" "*.jpg" "*.jpeg" "*.png"
          "*.tar.gz" "*.tar" "*.zip" "*.class" "*.pdb" "*.dll"
          "*.dat" "*.mca" "__pycache__" ".mozilla/" ".electron/"
          ".vpython-root/" ".gradle/" ".nuget/" ".cargo/"
          "yay/" ".local/share/Trash/"
          ".local/share/nvim/swap/" "code%-other/"
        ]
      }
    }
  )
)
