
(fn equal [lhs rhs]
  (var diff 0)
  (when (not (= (length lhs) (length rhs)))
    (set diff (+ 1 diff)))
  (each [k v (pairs lhs)]
    (when (not (= v (. rhs k)))
      (set diff (+ 1 diff))))
  (if (= diff 0)
    true
    nil))

(fn join-with-sep [sep list]
  (if (= nil list)
    "<nil>"
    (if (= (length list) 1)
      (car list)
      (.. (car list) sep (join-with-sep sep (cdr list))))))

(fn unpack [...] (table.unpack ...))

(fn join [...]
  (let [args [...]]
    (if (= 1 (length args))
      (let [(list) (unpack args)]
        (join-with-sep "" list))
      (let [(list sep) (unpack args)]
        (join-with-sep sep list)))))

(fn joint-with-sep [sep list]
  (var s "")
  (each [k v (pairs list)]
    (set s (.. s k ":" v " ")))
  s)

(fn joint-with-sep? [sep list]
  (if (= nil list)
    "<nil>"
    (joint-with-sep sep list)))

(fn joint [...]
  (let [args [...]]
    (if (= 1 (length args))
      (let [(tlist) (unpack args)]
        (joint-with-sep? "" tlist))
      (let [(tlist sep) (unpack args)]
        (joint-with-sep? sep tlist)))))

(fn log-msg [msg exp act]
  (var expstr (tostring exp))
  (var actstr (tostring act))
  (var joinexp join)
  (var joinact join)
  (when (= (type exp) :table)
    (when (not (= (length exp) (tlen exp)))
      (set joinexp joint))
    (set expstr (.. "[" (joinexp exp " ") "]")))
  (when (= (type act) :table)
    (when (not (= (length act) (tlen act)))
      (set joinact joint))
    (set actstr (.. "[" (joinact act " ") "]")))
  (.. msg "\nexpected: " expstr "\nactual:   " actstr "\n\n"))

(var list [1 2 3 4 5 6])
(var listclone [1 2 3 4 5 6])

(assert (= list list)                   "same list should be strictly equal")
(assert (not (= list listclone))        "equal list should not be strictly equal")
(assert (not (= list []))               "different list should not be strictly equal")

(assert (not (= list listclone))        "equal list should not be strictly equal")
(assert (equal list listclone)          "equal list should be equal")
(assert (not (equal list []))           "different list should not be equal")


(assert (= 1 (car list))                (log-msg "car should return first element" 1 (car list)))
(assert (equal [2 3 4 5 6] (cdr list))  (log-msg "cdr should return all elements but first" [2 3 4 5 6] (cdr list)))
(assert (equal list listclone)          (log-msg "car and cdr should not modify the element" list listclone))

(assert (= 1 (car [1]))                 (log-msg "car on single element list" 1 (car [1])))
(assert (= nil (car []))                (log-msg "car on empty list" nil (car [])))

(assert (equal [] (cdr [1]))            "cdr on single element list")
(assert (equal [] (cdr []))             "cdr on empty list")

(var s {:a 2 :b 3 :c 4})
(var t                {:d 5 :e 10 :f 15})
(var v {:a 2 :b 3 :c 4 :d 5 :e 10 })
(assert (equal (merge-table s t) {:a 2 :b 3 :c 4 :d 5 :e 10 :f 15}))
(assert (not (equal (merge-table s t) v)) (log-msg "merge table" {:a 2 :b 3 :c 4 :d 5 :e 10 } (merge-table s t)))


