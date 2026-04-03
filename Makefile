BR_VERSION := 2026.02
BR_ARCHIVE := buildroot-$(BR_VERSION).tar.gz
BR_URL     := https://buildroot.org/downloads/$(BR_ARCHIVE)

ROOT_DIR := $(CURDIR)
BR_DIR   := $(ROOT_DIR)/buildroot
BR_EXT   := $(ROOT_DIR)/br2-external
OUT_DIR  := $(ROOT_DIR)/output
DL_DIR   := $(ROOT_DIR)/dl
TMP_DIR  := $(ROOT_DIR)/.tmp

BR_ARGS = \
	BR2_EXTERNAL=$(BR_EXT) \
	BR2_DL_DIR=$(DL_DIR) \
	O=$(OUT_DIR)

.PHONY: all
all: build

.PHONY: buildroot
buildroot:
	@if [ -d "$(BR_DIR)" ]; then \
		echo "Buildroot already present: $(BR_DIR)"; \
	else \
		set -e; \
		echo "Buildroot missing, downloading $(BR_ARCHIVE)"; \
		mkdir -p "$(TMP_DIR)" "$(DL_DIR)"; \
		if [ ! -f "$(DL_DIR)/$(BR_ARCHIVE)" ]; then \
			curl -L "$(BR_URL)" -o "$(DL_DIR)/$(BR_ARCHIVE)"; \
		fi; \
		rm -rf "$(TMP_DIR)/buildroot-$(BR_VERSION)"; \
		tar -xzf "$(DL_DIR)/$(BR_ARCHIVE)" -C "$(TMP_DIR)"; \
		rm -rf "$(BR_DIR)"; \
		mv "$(TMP_DIR)/buildroot-$(BR_VERSION)" "$(BR_DIR)"; \
		echo "Buildroot installed in $(BR_DIR)"; \
	fi

.PHONY: defconfig
defconfig: buildroot
	$(MAKE) -C $(BR_DIR) $(BR_ARGS) myfw_x86_64_rauc_defconfig

.PHONY: menuconfig
menuconfig: buildroot
	$(MAKE) -C $(BR_DIR) $(BR_ARGS) menuconfig

.PHONY: build
build: defconfig
	$(MAKE) -C $(BR_DIR) $(BR_ARGS)

.PHONY: bundle
bundle: buildroot
	$(BR_EXT)/board/myfw/make-bundle.sh \
		$(OUT_DIR)/images \
		$(BR_EXT)/board/myfw

.PHONY: clean
clean: buildroot
	$(MAKE) -C $(BR_DIR) $(BR_ARGS) clean

.PHONY: distclean
distclean:
	rm -rf $(OUT_DIR) $(TMP_DIR)

.PHONY: realclean
realclean: distclean
	rm -rf $(BR_DIR)

.PHONY: show
show:
	@ls -lh $(OUT_DIR)/images || true
