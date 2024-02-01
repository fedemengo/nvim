(module mods.tools.trouble {autoload {trouble :trouble}})

(map [:n] :<leader>xx trouble.toggle {:desc "Toggle Trouble"})
