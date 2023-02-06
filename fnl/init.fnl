(module init {
  autoload {
    zest zest }})

;; load sensible macro
(zest.setup)

(fn remove [tab indx]
  (let [t tab] (table.remove t indx) t))

;; car and cdr to let the magic begin
(global car
  (fn [lst]
    (. lst 1)))

(global cdr
  (fn [lst]
    (remove lst 1)))

(global bindcmd (fn [cmds]
  (fn []
    (if (= (type cmds) :string)
      (vim.cmd cmds)
      (each [_ cmd (ipairs cmds)]
        (vim.cmd cmd))))))

(global bindf (fn [f args]
  (fn [] (f args))))

