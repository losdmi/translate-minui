ifeq ($(PLATFORMS),)
PLATFORMS := rg35xx
endif

MINUI_PATH := ./MinUI

# === <TOOLCHAIN_TEMPLATE> ===
define TOOLCHAIN_TEMPLATE

$1_TOOLCHAIN_REPO ?= https://github.com/shauninman/union-$(1)-toolchain
$1_TOOLCHAIN_PATH ?= $(MINUI_PATH)/toolchains/$(1)-toolchain

$$($1_TOOLCHAIN_PATH):
	git clone $$($1_TOOLCHAIN_REPO) $$@
	git -C $$@ checkout $$(shell cat ./hash-toolchain-$1.txt)

$$($1_TOOLCHAIN_PATH)/.patched: $$($1_TOOLCHAIN_PATH)
	(test ! -f patches/$(1)-toolchain.patch) || (test -f $$($1_TOOLCHAIN_PATH)/.patched) || (git -C $$($1_TOOLCHAIN_PATH) apply  -p1 < patches/$(1)-toolchain.patch && touch $$@ && true)

endef
# === </TOOLCHAIN_TEMPLATE> ===

# === === === === === === === ===

all: $(MINUI_PATH) toolchains
	PLATFORMS=$(PLATFORMS) $(MAKE) -C $(MINUI_PATH)

clean:
	rm -rf $(MINUI_PATH)

$(MINUI_PATH):
	git clone https://github.com/shauninman/MinUI $@
	git -C $@ checkout $(shell cat ./hash-minui.txt)

$(foreach PLATFORM,$(PLATFORMS),$(eval $(call TOOLCHAIN_TEMPLATE,$(PLATFORM))))

toolchains: clone-toolchains patch-toolchains
clone-toolchains: $(foreach PLATFORM,$(PLATFORMS),$(MINUI_PATH)/toolchains/$(PLATFORM)-toolchain)
patch-toolchains: $(foreach PLATFORM,$(PLATFORMS),$(MINUI_PATH)/toolchains/$(PLATFORM)-toolchain/.patched)
# build-toolchains: $(foreach PLATFORM,$(PLATFORMS),$(MINUI_PATH)/toolchains/$(PLATFORM)-toolchain/.build)

