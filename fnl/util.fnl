(module util)

;; load sensible macro
(let [zest (require :zest)]
  (zest.setup)
)

(fn table-insert [tab val]
  (var t tab)
  (table.insert t val)
  t)

(fn table-remove [tab indx]
  (var t tab)
  (table.remove t indx)
  t)

;; car and cdr to let the magic begin
(global car (fn [lst] (. lst 1)))
(global cdr (fn [lst] (table-remove lst 1)))

