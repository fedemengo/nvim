(module mods.ui.neoscroll {autoload {ns neoscroll config neoscroll.config}})

(ns.setup {:mappings [:<C-u> :<C-d> :<C-y> :<C-e> :zt :zz :zb]})

(map [:n :v :x] :<C-u> (bindf ns.ctrl_u {:move_cursor true :duration 250}))
(map [:n :v :x] :<C-d> (bindf ns.ctrl_d {:move_cursor true :duration 250}))
(map [:n :v :x] :<C-y> (bindf ns.scroll (- 0.1) {:move_cursor true :duration 100}))
(map [:n :v :x] :<C-e> (bindf ns.scroll 0.1 {:move_cursor true :duration 100}))
