(module :mods.dev.dap
        {autoload {dap dap
                   dapui dapui
                   dappy dap-python
                   mason-dap mason-nvim-dap}})

(mason-dap.setup {:ensure_installed [:python]
                  :handlers {}})

(dappy.setup (.. (vim.fn.stdpath :data) "/mason/packages/debugpy/venv/bin/python"))

(dapui.setup)

(local dap-keys-group (vim.api.nvim_create_augroup :dap-keys {:clear true}))

(tset dap.listeners.after.event_initialized :dapui_config
      (fn []
        (dapui.open)
        (vim.api.nvim_create_autocmd :BufEnter
                                     {:group dap-keys-group
                                      :callback (fn []
                                                  (map [:n] :c dap.continue  {:desc "Continue [DAP]" :buffer true})
                                                  (map [:n] :n dap.step_over {:desc "Step over [DAP]" :buffer true})
                                                  (map [:n] :s dap.step_into {:desc "Step into [DAP]" :buffer true})
                                                  (map [:n] :o dap.step_out  {:desc "Step out [DAP]"  :buffer true}))})))

(tset dap.listeners.before.event_terminated :dapui_config
      (fn []
        (dapui.close)
        (vim.api.nvim_clear_autocmds {:group dap-keys-group})))

(tset dap.listeners.before.event_exited :dapui_config
      (fn []
        (dapui.close)
        (vim.api.nvim_clear_autocmds {:group dap-keys-group})))

;; server-type adapter for attaching to a running debugpy process
(tset dap.adapters :python-attach
      {:type :server
       :host "127.0.0.1"
       :port 5678})

(tset dap.configurations :python
      [{:type :python-attach
        :request :attach
        :name "Attach (debugpy @ 5678)"
        :justMyCode false
        :pathMappings [{:localRoot (vim.fn.getcwd)
                        :remoteRoot (vim.fn.getcwd)}]}])

