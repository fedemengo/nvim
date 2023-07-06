# neovim config in lisp

<p align="center">
  <img src="https://imgs.xkcd.com/comics/lisp.jpg" />
</p>

Nvim config in fennel (lisp)

## Requirements

- [fennel](https://fennel-lang.org)
- npm - for some language server
- node16 - for copilot
- python3.10-venv
- fd/fd-find
- rg

other stuff for LSPs

- pylsp-mypy
- pep8

### Plugins

Different plugins will require different binaries, here some

- fd
- rg
- gopls
- prettier

## Bootstrap

Install required plugins with `:PackerInstall`, that's it

