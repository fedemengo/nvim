(module misc)

;; autocmd
(when (= 1 (vim.fn.has "autocmd"))
  (vim.cmd "autocmd BufRead \"$GOPATH/src/*/*.go\" :GoGuruScope ...")
)
