ifeq ($(PLATFORMS),)
PLATFORMS := rg35xx
endif

MINUI_PATH := ./MinUI

# === <TOOLCHAIN_TEMPLATE> ===
define TOOLCHAIN_TEMPLATE

$1_TOOLCHAIN_REPO ?= https://github.com/shauninman/union-$(1)-toolchain
$1_TOOLCHAIN_PATH ?= $(MINUI_PATH)/toolchains/$(1)-toolchain/

$$($1_TOOLCHAIN_PATH):
	git clone $$($1_TOOLCHAIN_REPO) $$@
	git -C $$@ checkout $$(shell cat ./hash-toolchain-$1.txt)

endef
# === </TOOLCHAIN_TEMPLATE> ===

# === === === === === === === ===

all: $(MINUI_PATH) clone-toolchains

clean:
	rm -rf $(MINUI_PATH)

$(MINUI_PATH):
	git clone https://github.com/shauninman/MinUI $@
	git -C $@ checkout $(shell cat ./hash-minui.txt)

$(foreach PLATFORM,$(PLATFORMS),$(eval $(call TOOLCHAIN_TEMPLATE,$(PLATFORM))))

clone-toolchains: $(foreach PLATFORM,$(PLATFORMS),$(MINUI_PATH)/toolchains/$(PLATFORM)-toolchain/)


