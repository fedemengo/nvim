(module mods.tools.persistence)

(local p (require :persistence))
(p.setup)

(fn save-named-session []
  (let [name (vim.trim (vim.fn.input "Session name: "))]
    (when (not= name "")
      (let [safe-name (name:gsub "[\\/:]+" "%%")
            dir (vim.fn.fnamemodify (p.current {:branch false}) ":h")
            file (.. dir "/" safe-name ".vim")]
        (vim.fn.mkdir dir :p)
        (vim.cmd (.. "mksession! " (vim.fn.fnameescape file)))
        (vim.notify (.. "Saved session '" name "' to " file))))))

(fn save-session []
  (p.save)
  (vim.notify "Saved session"))

(map [:n] :<space>qs (fn [] (p.load))            {:desc "Load session (cwd)"})
(map [:n] :<space>ql (fn [] (p.select))          {:desc "Select session"})
(map [:n] :<space>qS save-session                {:desc "Save session"})
(map [:n] :<space>qn save-named-session          {:desc "Save named session"})
(map [:n] :<space>qd (fn [] (p.stop))            {:desc "Stop session saving"})
(map [:n] :<space>qL (fn [] (p.load {:last true})) {:desc "Load last session"})
