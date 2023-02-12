(module init)

(fn tlen [t]
  (var c 0)
  (each [_ _ (pairs t)]
    (set c (+ 1 c)))
  c)

;; car and cdr to let the magic begin
(global car
  (fn [lst]
    (. lst 1)))

(global cdr
  (fn [lst]
    (local t [])
    (each [k v (ipairs lst)]
      (tset t k v))
    (table.remove t 1)
    (if (= (length lst) (tlen lst)) ;; lst is an array
      t
      nil)))

(global map vim.keymap.set)

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
  (fn [...]
    (let [f-args [...]  ;; first argument is function, then n args
          f (car f-args)
          args (cdr f-args)]
      (fn [call-args]
        (f (unpack (merge-table args call-args)))))))

(global bindcmd (fn [cmds]
  (fn []
    (if (= (type cmds) :string)
      (vim.cmd cmds)
      (each [_ cmd (ipairs cmds)]
        (vim.cmd cmd))))))

(require :core)
(require :mapping)
(require :plugins)

