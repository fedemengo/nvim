(module :mods.dev.log)

(var log {:version :0.1.0
          :caller true
          :usecolor true
          :outfile nil
          :level :trace})

(var modes [{:name :trace :color "\027[34m"}
            {:name :debug :color "\027[36m"}
            {:name :info :color "\027[32m"}
            {:name :warn :color "\027[33m"}
            {:name :error :color "\027[31m"}
            {:name :fatal :color "\027[35m"}])

(var levels {})
(each [lv name (ipairs modes)]
  (tset levels (. name :name) lv))

(fn round [v inc]
  (var inc (or inc 1))
  (var x (/ v inc))
  (if (> x 0)
      (* (math.floor (+ x 0.5)) inc)
      (* (math.ceil (- x 0.5)) inc)))

(global table-to-string (fn [t]
                          (var str "")
                          (each [k v (pairs t)]
                            (case (type! v) :table
                                  (set str
                                       (string.format "%s\"%s\": %s, " str
                                                      (val-to-string k)
                                                      (table-to-string v)))
                                  :list
                                  (set str
                                       (string.format "%s\"%s\": %s, " str
                                                      (val-to-string k)
                                                      (list-to-string v)))
                                  _
                                  (set str
                                       (string.format "%s\"%s\": \"%s\", " str
                                                      (val-to-string k)
                                                      (val-to-string v)))))
                          (set str (string.sub str 1 -3))
                          (string.format "{%s}" str)))

(global list-to-string (fn [t]
                         (var str "")
                         (each [k v (pairs t)]
                           (case (type! v) :table
                                 (set str
                                      (string.format "%s\"%s\", " str
                                                     (table-to-string v)))
                                 :list
                                 (set str
                                      (string.format "%s\"%s\", " str
                                                     (list-to-string v)))
                                 :number
                                 (set str
                                      (string.format "%s%s, " str
                                                     (val-to-string v)))
                                 _
                                 (set str
                                      (string.format "%s\"%s\", " str
                                                     (val-to-string v)))))
                         (set str (string.sub str 1 -3))
                         (string.format "[%s]" str)))

(global val-to-string (fn [...]
                        (var t {})
                        (var args [...])
                        (each [i v (ipairs args)]
                          (case (type! v) :number (tset t i (round v 0.01))
                                :table (tset t i (table-to-string v)) :list
                                (tset t i (list-to-string v)) :function
                                (tset t i :<func>) _ (tset t i (tostring v))))
                        (table.concat t " ")))

(each [i mode (ipairs modes)]
  (var upper (string.upper (. mode :name)))
  (tset log (. mode :name) (fn [...]
                             (when (>= i (. levels (. log :level)))
                               (var msg (val-to-string ...))
                               (var info (debug.getinfo 2 :Sl))
                               (var short (or (?. info :short_src) ""))
                               (var cline (?. info :currentline))
                               (var home (or (os.getenv :HOME) "~"))
                               (set short (short:gsub (.. home :/.dotfiles/.config/nvim)
                                                      :nvim/))
                               (set short (short:gsub (.. home :/.config/nvim)
                                                      :nvim/))
                               (set short (short:gsub home "~"))
                               (var lineinfo short)
                               (when cline
                                 (set lineinfo (.. short ":" cline)))
                               (when (. log :outfile)
                                 (let [f (io.open (. log :outfile) :a)]
                                   (var str
                                        (string.format "%s[%-6s%s]%s %s %s"
                                                       (if (. log :usecolor)
                                                           (. mode :color)
                                                           "")
                                                       upper
                                                       (os.date "%H:%M:%S")
                                                       (if (. log :usecolor)
                                                           "\027[0m"
                                                           "")
                                                       (if (. log :caller)
                                                           lineinfo
                                                           "")
                                                       msg))
                                   (when f
                                     (f:write (.. str "\n"))
                                     (f:close))))))))

(tset log :setcolor (fn [v]
                      (tset log :usecolor v)))

(tset log :setcaller (fn [v]
                       (tset log :caller v)))

(tset log :setfile (fn [v]
                     (tset log :outfile v)))

(tset log :setup (fn [opts]
                   (each [k v (pairs opts)]
                     (tset log k v))
                   log))

log
