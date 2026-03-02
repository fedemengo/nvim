(module init)

(require :umacros/util)
(require :umacros/nvim)

(set vim.o.termguicolors true)
(set vim.g.mapleader ";")
(require :plugins)
(require :core)
(require :mapping)
