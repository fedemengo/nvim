(var log {
          :version "0.1.0"
          :caller true
          :usecolor true
          :outfile nil
          :level "trace" })

(var modes [
            {:name "trace" :color "\27[34m"}
            {:name "debug" :color "\27[36m"}
            {:name "info"  :color "\27[32m"}
            {:name "warn"  :color "\27[33m"}
            {:name "error" :color "\27[31m"}
            {:name "fatal" :color "\27[35m"}])

(var levels {})
(each [lv name (ipairs modes)]
  (tset levels (. name :name) lv))

(fn round [v inc]
  (var inc (or inc 1))
  (var x (/ v inc))
  (if (> x 0)
    (* (math.floor (+ x 0.5)) inc)
    (* (math.ceil (- x 0.5)) inc)))

(var _tostring tostring)

(global tabletostring
  (fn [t]
    (var str "")
    (each [k v (pairs t)]
      (case (type v)
        "table" (set str (string.format "%s\"%s\": %s, " str (vtostring k) (tabletostring v)))
        _ (set str (string.format "%s\"%s\": %s, " str (vtostring k) (vtostring v)))))
    (set str (string.sub str 1 -3))
    (string.format "{%s}" str)))

(global vtostring
  (fn [...]
    (var t {})
    (var args [...])
    (each [i v (ipairs args)]
      (case (type v)
        "number" (tset t i (round v 0.01))
        "table"  (tset t i (tabletostring v))
        _ (tset t i (_tostring v))))
    (table.concat t " ")))

(each [i mode (ipairs modes)]
  (var upper (string.upper (. mode :name)))
  (tset log (. mode :name) (fn [...]
                    (when (>= i (. levels (. log :level)))
                      (var msg (vtostring [...]))
                      (var info (debug.getinfo 2 "Sl"))
                      (var short info.short_src)
                      (var home (or (os.getenv "HOME") "~"))
                      (short:gsub (.. home "/.dotfiles/.config/nvim") "nvim/")
                      (short:gsub (.. home "/.config/nvim") "nvim/")
                      (short:gsub home "~")
                      (var lineinfo (.. short ":" info.currentline))
                      (when (. log :outfile)
                        (let [f (io.open (. log :outfile) "a")]
                          (var str (string.format "%s[%-6s%s]%s %s %s"
                                                  (if (. log :usercolor)
                                                    (. mode :color)
                                                    "")
                                                  upper
                                                  (os.date "%H:%M:%S")
                                                  (if (. log :usercolor)
                                                    "\27[0m"
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

