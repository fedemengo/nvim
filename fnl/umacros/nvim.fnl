(module umacros/nvim)

(global map vim.keymap.set)
(global unmap vim.keymap.del)

(global bindf
        (fn [...]
          (let [f-args [...] ;; first argument is function, then n args
                func (car f-args)
                args (cdr f-args)]
            (fn [call-args]
              (func (unpack (merge-table args call-args)))))))

(global bindcmd (fn [cmds]
                  (fn []
                    (if (= (type cmds) :string)
                        (vim.cmd cmds)
                        (each [_ cmd (ipairs cmds)]
                          (vim.cmd cmd))))))
