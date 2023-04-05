(var profile (require :profile))
(var on false)

(fn start-and-log []
  (when (not (profile.is_recording))
    (profile.start "*")
    (print "profiler started")))

(when on 
  (let [pval (or (os.getenv :NVIM_PROFILE) "")
        lower (string.lower pval)]
    (if (string.match lower "^start")
      (start-and-log)
      (profile.instrument "*"))))

(fn save [filename]
  (profile.export filename)
  (vim.notify "Profile saved"))

(fn stop-and-save []
  (profile.stop)
  (vim.ui.input {:prompt "Save profile to: "
                 :completion "file"
                 :default "profile.json" }
                (fn [filename]
                  (when filename
                    (save filename)))))

(fn toggle-profile []
  (if (profile.is_recording)
    (stop-and-save)
    (start-and-log)))

(vim.keymap.set [:n] "]p"      toggle-profile  {:desc "Toggle profiler"})

