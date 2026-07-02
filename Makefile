PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin

.PHONY: install uninstall check

install:
	DOCKEROP_INSTALL_DIR="$(BINDIR)" ./install.sh

uninstall:
	DOCKEROP_INSTALL_DIR="$(BINDIR)" ./uninstall.sh

check:
	python3 -m py_compile dockerop
	./dockerop --help >/dev/null
	./dockerop --version >/dev/null
