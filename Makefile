.PHONY: clean test-headless test-install test-functional clean-install-test

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
	mkdir -p $(NVIM_TEST_DIR)/data $(NVIM_TEST_DIR)/cache $(NVIM_TEST_DIR)/state $(NVIM_TEST_DIR)/config
	ln -sf $(CURDIR) $(NVIM_TEST_DIR)/config/nvim
	XDG_CONFIG_HOME=$(NVIM_TEST_DIR)/config \
	XDG_DATA_HOME=$(NVIM_TEST_DIR)/data \
	XDG_CACHE_HOME=$(NVIM_TEST_DIR)/cache \
	XDG_STATE_HOME=$(NVIM_TEST_DIR)/state \
	$(NVIM) --headless "+Lazy! sync" +qa
	XDG_CONFIG_HOME=$(NVIM_TEST_DIR)/config \
	XDG_DATA_HOME=$(NVIM_TEST_DIR)/data \
	XDG_CACHE_HOME=$(NVIM_TEST_DIR)/cache \
	XDG_STATE_HOME=$(NVIM_TEST_DIR)/state \
	$(NVIM) --headless +qa

test-functional:
	XDG_CONFIG_HOME=$(NVIM_TEST_DIR)/config \
	XDG_DATA_HOME=$(NVIM_TEST_DIR)/data \
	XDG_CACHE_HOME=$(NVIM_TEST_DIR)/cache \
	XDG_STATE_HOME=$(NVIM_TEST_DIR)/state \
	$(NVIM) --headless "+lua require('aniseed.fennel').impl().dofile('tests/headless.fnl')" "+cquit! 1"

clean-install-test:
	rm -rf $(NVIM_TEST_DIR)
