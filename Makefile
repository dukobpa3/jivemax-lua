#
# Main Makefile for jivemax-lua build
#
# This Makefile acts as a dispatcher to build either LuaJIT or a
# patched vanilla Lua 5.1.5 with BitOp.
#
# --- Configuration ---
#
# USE_LUAJIT     - Set to 0 to build vanilla Lua instead of LuaJIT.
#                  Default: 1 (builds LuaJIT).
#
# --- Usage ---
#
# make [target]                - Builds LuaJIT.
# make [target] USE_LUAJIT=0   - Builds vanilla Lua.
#
# Any target (e.g., all, clean, install, linux) is forwarded to the
# selected Lua implementation's Makefile.
#

# Use LuaJIT by default (1 = yes, 0 = no)
USE_LUAJIT ?= 1

# Default platform if not specified from the top-level build.
PLAT ?= generic

# --- Logic ---

# Determine the source directory based on the switch
ifeq ($(USE_LUAJIT), 1)
	LUA_SRC_DIR := luajit
else
	LUA_SRC_DIR := lua-5.1.5
endif

# Export all variables (like PREFIX, CFLAGS, etc.) to sub-makefiles.
export

# --- Targets ---

# Provide a specific test target for vanilla lua, as it has a custom test.
.PHONY: test
test:
ifeq ($(USE_LUAJIT), 0)
	@echo "--- Testing Vanilla Lua 5.1.5 with BitOp integration for $(PLAT) ---"
	@# First, we need to build it to be able to test it for the target platform.
	@$(MAKE) -C $(LUA_SRC_DIR) $(PLAT)
	@./$(LUA_SRC_DIR)/src/lua ./$(LUA_SRC_DIR)/test/bittest.lua
	@echo "--- Test successful! ---"
else
	@echo "--- Forwarding target '$@' to $(LUA_SRC_DIR) ---"
	@$(MAKE) -C $(LUA_SRC_DIR) $@
endif

# A catch-all phony target that forwards any command to the selected
# subdirectory's Makefile. This must come after 'test' to avoid catching it.
.PHONY: %
%:
	@echo "--- Forwarding target '$@' to $(LUA_SRC_DIR) ---"
	@$(MAKE) -C $(LUA_SRC_DIR) $@
