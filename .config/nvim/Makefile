.PHONY: all
all: types

TYPES_DIR := ~/.local/share/nvim/types

.PHONY: types
types: $(TYPES_DIR)/luv

$(TYPES_DIR)/luv:
	mkdir -p "$@"
	wget --directory-prefix="$@" \
		https://raw.githubusercontent.com/luvit/luv/refs/tags/1.51.0-1/docs/meta.lua

# vim: noet ts=4 sw=4
