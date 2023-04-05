
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

(fn assert-prefix [exp act msg]
  (assert (= (string.sub act 1 (string.len exp)) exp) (log-msg msg exp act)))

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
(assert= (length s) 0  "length of table")
(assert= (length t) 0  "length of table")
(assert= (length v) 0  "length of table")
(assert= (length [1 2 3 4]) 4  "length of table")
(assert= (lengtht [1 2 3 4]) 4  "length of table")

(assert= (type! s) :table "type of table")
(assert= (type! [1 2 3 4]) :list "type of list")

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

(assert-eq {:a 1 :b 2} (omit {:a 1 :b 2 :c 3} [:c]) "omit should remove the key")
(assert-eq {:z 1} (omit {:a 1 :b 2 :c 3 :z 1} [:a :b :c]) "omit should remove the key")

(assert-eq {:a 1 :b 2 :c 3} (deep-copy {:a 1 :b 2 :c 3}) "deep copy should copy the table")
(var q {:a 1 :b 2 :c 3})
(var t1 (deep-copy q))
(var t2 (deep-copy q))
(assert-eq t1 t2 "deep copied tables should be equal")
(tset t1 :a 2)
(assert-neq t1 t2 "tables should be different")
(assert-neq t1 q "tables should be different")
(assert-eq t2 q "tables should remain equal")
(assert-eq t1 {:a 2 :b 2 :c 3} "deep copy should copy the table")

(assert=        256 (safe-eval "2^8") "2^8 should be 256")
;;(assert-prefix  "err" (safe-eval "2^x8") "2^8 should be 256")
(assert= 2 (min 2 3) "min of 2 and 3 should be 2")
(assert= 3 (max 2 3) "max of 2 and 3 should be 3")

