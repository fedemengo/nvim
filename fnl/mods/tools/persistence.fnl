(module mods.tools.persistence)

(local p (require :persistence))
(p.setup)

(map [:n] :<space>qs (fn [] (p.load))            {:desc "Load session (cwd)"})
(map [:n] :<space>ql (fn [] (p.select))          {:desc "Select session"})
(map [:n] :<space>qS (fn [] (p.save))            {:desc "Save session"})
(map [:n] :<space>qd (fn [] (p.stop))            {:desc "Stop session saving"})
(map [:n] :<space>qL (fn [] (p.load {:last true})) {:desc "Load last session"})
