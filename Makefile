################################################################################
# Main Makefile for jivemax-lua build
#
# This Makefile dispatches build commands to either LuaJIT or a patched
# vanilla Lua 5.1.5, based on the USE_LUAJIT switch.
#
# It is designed to be called from the main project's Makefile and inherits
# environment variables like PREFIX, CFLAGS, etc.
################################################################################

# --- Configuration ---
# USE_LUAJIT: Set to 0 for vanilla Lua, 1 for LuaJIT. Default is 1.
USE_LUAJIT ?= 1

# Default platform if not specified.
PLAT ?= linux

# --- Logic ---
# Determine the source directory based on USE_LUAJIT.
ifeq ($(USE_LUAJIT), 1)
	LUA_SRC_DIR := luajit
else
	LUA_SRC_DIR := lua-5.1.5
endif

# Export variables to sub-makefiles.
export

# --- Main Targets ---

# 'all' is the main build and install target.
.PHONY: all
all:
ifeq ($(USE_LUAJIT), 1)
	@echo "--- Building and installing LuaJIT ---"
	@$(MAKE) -C $(LUA_SRC_DIR)
	@$(MAKE) -C $(LUA_SRC_DIR) install
else
	@echo "--- Building and installing vanilla Lua ---"
	@$(MAKE) -C $(LUA_SRC_DIR) $(PLAT) install
endif

# 'install' is an alias for 'all'.
.PHONY: install
install: all

.PHONY: clean
clean:
	@echo "--- Cleaning $(LUA_SRC_DIR) ---"
	@$(MAKE) -C $(LUA_SRC_DIR) clean

# --- Test Target ---
# Explicit test logic, does not rely on a generic forwarder.
.PHONY: test
test:
ifeq ($(USE_LUAJIT), 0)
	@echo "--- Building vanilla Lua for testing ---"
	@$(MAKE) -C $(LUA_SRC_DIR) $(PLAT)
	@echo "--- Testing Vanilla Lua 5.1.5 with BitOp integration ---"
	@./$(LUA_SRC_DIR)/src/lua ./$(LUA_SRC_DIR)/test/bittest.lua
	@echo "--- Test successful! ---"
else
	@echo "--- Running tests for LuaJIT ---"
	@$(MAKE) -C $(LUA_SRC_DIR) test
endif
