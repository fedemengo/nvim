.PHONY: clean test-headless test-install clean-install-test

NVIM ?= nvim
NVIM_DATA ?= $(HOME)/.local/share/nvim
NVIM_TEST_DIR ?= /tmp/nvim-install-test

clean:
	rm -rf $(NVIM_DATA)/site/pack/packer
	rm -rf lua plugin
	rm -f nvim.log test.fnl

test-headless:
	XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache $(NVIM) --headless '+qa'

test-install:
	mkdir -p $(NVIM_TEST_DIR)/{data,cache,state,config}
	ln -sf $(CURDIR) $(NVIM_TEST_DIR)/config/nvim
	XDG_CONFIG_HOME=$(NVIM_TEST_DIR)/config \
	XDG_DATA_HOME=$(NVIM_TEST_DIR)/data \
	XDG_CACHE_HOME=$(NVIM_TEST_DIR)/cache \
	XDG_STATE_HOME=$(NVIM_TEST_DIR)/state \
	$(NVIM) --headless -c "autocmd User LazyDone ++once qall" -c "Lazy! sync"
	XDG_CONFIG_HOME=$(NVIM_TEST_DIR)/config \
	XDG_DATA_HOME=$(NVIM_TEST_DIR)/data \
	XDG_CACHE_HOME=$(NVIM_TEST_DIR)/cache \
	XDG_STATE_HOME=$(NVIM_TEST_DIR)/state \
	$(NVIM) --headless -c 'qall'

clean-install-test:
	rm -rf $(NVIM_TEST_DIR)
