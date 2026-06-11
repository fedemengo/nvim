;; Functional tests run headless inside the installed test environment:
;;   make test-install && make test-functional

(local failures [])

(fn check [cond msg]
  (when (not cond)
    (table.insert failures msg)))

(local (ok err)
       (pcall (fn []
                (let [lazy (require :lazy)]
                  (lazy.load {:plugins [:oil.nvim :telescope.nvim]}))
                (let [config (vim.fn.stdpath :config)
                      telescope-mod (require :mods.tools.telescope)
                      buffer-dir (. telescope-mod :buffer-dir)]
                  (check (= :function (type buffer-dir))
                         "mods.tools.telescope should export buffer-dir")
                  ;; oil buffer: cwd resolves to the directory oil is showing
                  (vim.cmd.edit (.. config :/fnl))
                  (check (= :oil vim.bo.filetype)
                         (.. "editing a directory should open an oil buffer, got ft="
                             vim.bo.filetype))
                  (var dir (or (buffer-dir) "<nil>"))
                  (check (not (dir:match "^oil://"))
                         (.. "buffer-dir should strip the oil:// scheme, got " dir))
                  (check (= 1 (vim.fn.isdirectory dir))
                         (.. "buffer-dir should return a real directory, got " dir))
                  (check (vim.endswith dir :/fnl)
                         (.. "buffer-dir should return the directory oil is showing, got "
                             dir))
                  ;; regular buffer: falls back to telescope's buffer_dir
                  (vim.cmd.edit (.. config :/init.lua))
                  (set dir (or (buffer-dir) "<nil>"))
                  (check (= 1 (vim.fn.isdirectory dir))
                         (.. "buffer-dir fallback should return a real directory, got "
                             dir))
                  ;; bundled treesitter parsers must stay on the rtp
                  ;; (lazy's rtp reset guesses lib64 over lib/nvim)
                  (let [(add-ok available) (pcall vim.treesitter.language.add
                                                  :markdown)]
                    (check (and add-ok available)
                           "markdown treesitter parser should be available"))
                  (let [(edit-ok edit-err) (pcall vim.cmd.edit
                                                  (.. config :/README.md))]
                    (check edit-ok
                           (.. "opening a markdown file should not error: "
                               (tostring edit-err))))))))

(when (not ok)
  (table.insert failures (.. "test run errored: " (tostring err))))

(if (> (length failures) 0)
    (do
      (each [_ f (ipairs failures)]
        (print (.. "FAIL: " f)))
      (vim.cmd "cquit! 1"))
    (do
      (print "OK: headless tests passed")
      (vim.cmd "quitall!")))
