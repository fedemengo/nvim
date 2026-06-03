.PHONY: clean test-headless

NVIM ?= nvim
NVIM_DATA ?= $(HOME)/.local/share/nvim

clean:
	rm -rf $(NVIM_DATA)/site/pack/packer
	rm -rf lua plugin
	rm -f nvim.log test.fnl

test-headless:
	XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache $(NVIM) --headless '+qa'
