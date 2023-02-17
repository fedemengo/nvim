(module init)

(fn tlen [t]
  (var c 0)
  (each [_ _ (pairs t)]
    (set c (+ 1 c)))
  c)

;; car and cdr to let the magic begin
(global car
  (fn [lst]
    "Returns the first item of the list"
    (. lst 1)))

(global cdr
  (fn [lst]
    "Returns the part of the list that follows the first item or nil if <arg> is not a list"
    (local t [])
    (each [k v (ipairs lst)]
      (when (> k 2)
        (tset t (- k 1) v)))
    (if (= (length lst) (tlen lst)) ;; lst is an array - it has only numeric keys
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

(global bindcmd
  (fn [cmds]
    (fn []
      (if (= (type cmds) :string)
        (vim.cmd cmds)
        (each [_ cmd (ipairs cmds)]
          (vim.cmd cmd))))))

(require :core)
(require :mapping)
(require :plugins)

