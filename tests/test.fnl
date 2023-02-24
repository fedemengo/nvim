
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
    (if (= (length list) 0)
      ""
      (if (= (length list) 1)
        (car list)
        (.. (car list) sep (join-with-sep sep (cdr list)))))))

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
  (var msgstr "assertion failed")
  (when (not (= nil msg))
    (set msgstr msg))
  (var expstr (tostring exp))
  (var actstr (tostring act))
  (var joinexp join)
  (var joinact join)
  (when (= (type! exp) :table)
    (set joinexp joint)
    (set expstr (.. "[" (joinexp exp " ") "]")))
  (when (= (type! act) :table)
    (set joinact joint)
    (set actstr (.. "[" (joinact act " ") "]")))
  (.. msgstr "\nexpected: " expstr "\nactual:   " actstr "\n"))

(fn assert= [exp act msg]
  (assert (= exp act) (log-msg msg exp act)))

(fn assert!= [exp act msg]
  (assert (not (= exp act)) (log-msg msg exp act)))

(fn assert-eq [exp act msg]
  (assert (equal exp act) (log-msg msg exp act)))

(fn assert-neq [exp act msg]
  (assert (not (equal exp act)) (log-msg msg exp act)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; test cases

(var list [1 2 3 4 5 6])
(var listclone [1 2 3 4 5 6])

(assert=    list list                 "same list should be strictly equal")
(assert!=   list listclone            "equal list should not be strictly equal")
(assert!=   list []                   "different list should not be strictly equal")

(assert!=   list listclone            "equal list should not be strictly equal")
(assert-eq  list listclone            "equal list should be equal")
(assert-neq list []                   "different list should not be equal")


(assert= 1  (car list)                "car should return first element")
(assert-eq  [2 3 4 5 6] (cdr list)    "cdr should return all elements but first")
(assert-eq  list listclone            "car and cdr should not modify the element")

(assert=    1 (car [1])               "car on single element list")
(assert=    nil (car [])              "car on empty list")

(assert-eq  [] (cdr [1])              "cdr on single element list")
(assert-eq  [] (cdr [])               "cdr on empty list")

(var s {:a 2 :b 3 :c 4})
(var t                {:d 5 :e 10 :f 15})
(var v {:a 2 :b 3 :c 4 :d 5 :e 10 })

(assert= (lengtht s) 3 "length of table")
(assert= (lengtht v) 5 "length of table")

(assert-eq  (merge-table s t) {:a 2 :b 3 :c 4 :d 5 :e 10 :f 15})
(assert-neq (merge-table s t) v "merge table")

(assert= true (in 2 [1 2 3]))
(assert= true (in 2 {:a 1 :b 2 :c 3}))
(assert= false (in 2 [1 3 4]))
(assert= false (in 2 {:a 1 :b 3 :c 4}))

;;(cons s t)
(assert-eq [1 2 3 4 5 6] (cons [1 2 3] [4 5 6]))
(var nums1 [1 2 3])
(var nums2 [4 5 6])
(assert-eq [1 2 3 4 5 6] (cons nums1 nums2))
(assert-eq [1 2 3] nums1 "cons should not modify the element")
(assert-eq [4 5 6] nums2 "cons should not modify the element")
(assert-eq [1 2 3 4 5 6] (cons [1 2 3 4 5] 6))

