(module mods.ui.startify)

(set vim.g.startify_session_sort 1)
(set vim.g.startify_files_number 8)
(set vim.g.startify_bookmarks
     (vim.fn.systemlist "cut -sd' ' -f 2- ~/.nvim-bookmarks"))
(set vim.g.startify_custom_header "startify#center(startify#fortune#cowsay())")

(set vim.g.startify_commands [[:Health :checkhealth] ["Quit all" :qa!]])

(fn git-modified []
  (let [files (vim.fn.systemlist "git ls-files -m 2>/dev/null")]
    (vim.fn.map files "{'line': v:val, 'path': v:val}")))

(fn git-untracked []
  (let [files (vim.fn.systemlist "git ls-files -o --exclude-standard 2>/dev/null")]
    (vim.fn.map files "{'line': v:val, 'path': v:val}")))

(set vim.g.startify_lists
     [{:type :bookmarks :header ["   Bookmarks"]}
      {:type :sessions :header ["   Sessions"]}
      {:type :files :header ["   MRU"]}
      {:type :dir :header [(.. "   MRU in " (vim.fn.getcwd))]}
      {:type :commands :header ["   Commands"]}
      {:type git-modified :header ["   Git modified"]}
      {:type git-untracked :header ["   Git untracked"]}])
