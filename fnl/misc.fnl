(module misc)

;; autocmd
(when (= 1 (vim.fn.has "autocmd"))
  (vim.cmd "autocmd BufRead \"$GOPATH/src/*/*.go\" :GoGuruScope ...")
)

(set vim.g.loaded_netrw 1)
(set vim.g.loaded_netrwPlugin 1)

(let [indent (require :indent_blankline)
      nvimtree (require :nvim-tree)
      colorizer (require :colorizer)
      leap (require :leap)
      fterm (require :FTerm)]
  (indent.setup)
  (nvimtree.setup)
  (colorizer.setup)
  (leap.add_default_mappings)
  (fterm.setup {
    :border "solid"
    :dimensions {
      :height 0.9
      :width 0.9
    }
  })
)

