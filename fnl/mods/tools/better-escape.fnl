(module mods.tools.better-escape)

(local interval 200)

(set vim.o.timeoutlen interval)
(set vim.o.updatetime interval)

(set vim.g.better_escape_interval interval)
(set vim.g.better_escape_shortcut "jk")

