(module init {
  autoload {
    zest zest }})

;; load sensible macro
(zest.setup)

(fn remove [tab indx]
  (table.remove tab indx)
  tab)

;; car and cdr to let the magic begin
(global car
  (fn [lst]
    (. lst 1)))

(global cdr
  (fn [lst]
    (remove lst 1)))

(global map vim.keymap.set)

(global bindcmd (fn [cmds]
  (fn []
    (if (= (type cmds) :string)
      (vim.cmd cmds)
      (each [_ cmd (ipairs cmds)]
        (vim.cmd cmd))))))

(global merge-table (fn [a b]
  (let [t {}]
    (when a
      (each [key val (pairs a)]
        (tset t key val)))
    (when b
      (each [key val (pairs b)]
        (tset t key val)))
  t)))

(global bindf
  (fn [f f-args]
    (fn [call-args]
      (f (merge-table f-args call-args)))))


(require :core)
(require :mapping)
(require :plugins)

