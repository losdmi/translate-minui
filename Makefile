ifeq ($(PLATFORMS),)
PLATFORMS := rg35xx
endif

ifeq ($(LANG),)
LANG := RU
endif

MINUI_PATH := ./MinUI
TRANSLATION_PATCH_PATH := patches/MinUI-$(LANG).patch

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

build: $(MINUI_PATH) toolchains
	PLATFORMS=$(PLATFORMS) $(MAKE) -C $(MINUI_PATH)
	$(MAKE) open

clean:
	rm -rf $(MINUI_PATH)

translation-build-template: patch-gather phrases-gather

patch-gather:
	git -C $(MINUI_PATH) diff --minimal --ignore-all-space > patches/MinUI.patch

phrases-gather:
	go run cmd/gather_phrases/main.go

translation-build-patch:
	go run cmd/generate_translation_patch/main.go $(LANG)

translation-apply: $(MINUI_PATH)/.translated

patch-apply-template:
	git -C $(MINUI_PATH) apply  -p1 < patches/MinUI.patch

$(MINUI_PATH)/.translated: $(TRANSLATION_PATCH_PATH)
	(\
	test ! -f $(TRANSLATION_PATCH_PATH)) \
	|| (test -f $(MINUI_PATH)/.translated) \
	|| (git -C $(MINUI_PATH) checkout -f HEAD \
	&& cp MPLUSRounded1c-ExtraBold.ttf $(MINUI_PATH)/skeleton/SYSTEM/res/ \
	&& git -C $(MINUI_PATH) apply  -p1 < $(TRANSLATION_PATCH_PATH) \
	&& touch $@ \
	&& true\
	)

open:
	open $(MINUI_PATH)/build/BASE

$(MINUI_PATH):
	git clone https://github.com/shauninman/MinUI $@
	git -C $@ checkout $(shell cat ./hash-minui.txt)

$(foreach PLATFORM,$(PLATFORMS),$(eval $(call TOOLCHAIN_TEMPLATE,$(PLATFORM))))

toolchains: clone-toolchains patch-toolchains
clone-toolchains: $(foreach PLATFORM,$(PLATFORMS),$(MINUI_PATH)/toolchains/$(PLATFORM)-toolchain)
patch-toolchains: $(foreach PLATFORM,$(PLATFORMS),$(MINUI_PATH)/toolchains/$(PLATFORM)-toolchain/.patched)
# build-toolchains: $(foreach PLATFORM,$(PLATFORMS),$(MINUI_PATH)/toolchains/$(PLATFORM)-toolchain/.build)
