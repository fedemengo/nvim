(module init)

(global lengtht
  (fn [t]
    "Returns the length of a proper table"
    (accumulate [len 0
                 _ _ (pairs t)]
      (+ len 1))))

(global type!
  (fn [x]
    "Return the type of an object, discriminating between lists and tables"
    (if (= (type x) :table)
      (if (= (length x) (lengtht x))
        :list
        :table)
      (type x))))

(global in
  (fn [x lst]
    "Returns true if <x> is in <lst>"
    (var found nil)
    (each [k v (pairs lst)]
      (when (= x v)
        (set found true)))
    found))

;; car and cdr to let the magic begin
(global car
  (fn [lst]
    "Returns the first item of the list"
    (if (in (type! lst) [:number :string])
      lst
      (. lst 1))))

(global cdr
  (fn [lst]
    "Returns the part of the list that follows the first item or nil if <arg> is not a list"
    (local t [])
    (each [k v (ipairs lst)]
      (when (> k 1)
        (tset t (- k 1) v)))
    (if (= (type! lst) :list)
      t
      nil)))

(fn append [lhs v]
  (var nl [])
  (each [k v (ipairs lhs)]
    (tset nl k v))
  (table.insert nl v)
  nl)

(global cons
  (fn [_lhs _rhs]
    (assert (not (in (type! _lhs) [:function :table])))
    (assert (not (in (type! _rhs) [:function :table])))
    (var lhs _lhs)
    (var rhs _rhs)
    (when (in (type! lhs) [:number :string])
      (set lhs [lhs]))
    (when (in (type! rhs) [:number :string])
      (set rhs [rhs]))
    (if (= 0 (length rhs))
      lhs
      (cons (append lhs (car rhs)) (cdr rhs)))))

(global map vim.keymap.set)
(global unmap vim.keymap.del)

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

