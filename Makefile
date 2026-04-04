BR_VERSION ?= 2026.02
BR_ARCHIVE := buildroot-$(BR_VERSION).tar.gz
BR_URL := https://buildroot.org/downloads/$(BR_ARCHIVE)

ROOT_DIR := $(CURDIR)
BR_DIR   := $(ROOT_DIR)/buildroot
BR_EXT   := $(ROOT_DIR)/br2-external
OUT_DIR  := $(ROOT_DIR)/output
DL_DIR   := $(ROOT_DIR)/dl
TMP_DIR  := $(ROOT_DIR)/.tmp
IMAGES_DIR := $(OUT_DIR)/images
IMG_ARTIFACT := $(IMAGES_DIR)/myfw.img
VERSION ?= 1.0.1
BUNDLE_ARTIFACT := $(IMAGES_DIR)/update-$(VERSION).raucb

BR_ARGS = \
	BR2_EXTERNAL=$(BR_EXT) \
	BR2_DL_DIR=$(DL_DIR) \
	O=$(OUT_DIR)

.PHONY: all
all: firmware bundle

.PHONY: buildroot
buildroot:
	@if [ -d "$(BR_DIR)" ]; then \
		echo "Buildroot already present: $(BR_DIR)"; \
	else \
		set -e; \
		echo "Buildroot missing, downloading $(BR_ARCHIVE)"; \
		mkdir -p "$(TMP_DIR)" "$(DL_DIR)"; \
		if [ ! -f "$(DL_DIR)/$(BR_ARCHIVE)" ]; then \
			if command -v curl >/dev/null 2>&1; then \
				curl -L "$(BR_URL)" -o "$(DL_DIR)/$(BR_ARCHIVE)"; \
			elif command -v wget >/dev/null 2>&1; then \
				wget -O "$(DL_DIR)/$(BR_ARCHIVE)" "$(BR_URL)"; \
			else \
				echo "error: need curl or wget to download Buildroot" >&2; \
				exit 1; \
			fi; \
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

.PHONY: firmware
firmware: $(IMG_ARTIFACT)

$(IMG_ARTIFACT): defconfig
	$(MAKE) -C $(BR_DIR) $(BR_ARGS)

.PHONY: bundle
bundle: $(BUNDLE_ARTIFACT)

$(BUNDLE_ARTIFACT): firmware
	VERSION="$(VERSION)" \
	$(BR_EXT)/board/myfw/make-bundle.sh \
		$(IMAGES_DIR) \
		$(BR_EXT)/board/myfw

.PHONY: artifacts
artifacts: firmware bundle

.PHONY: clean
clean:
	@if [ -d "$(BR_DIR)" ]; then \
		$(MAKE) -C $(BR_DIR) $(BR_ARGS) clean; \
	else \
		rm -rf "$(OUT_DIR)"; \
	fi

.PHONY: distclean
distclean:
	rm -rf $(OUT_DIR) $(TMP_DIR)

.PHONY: realclean
realclean: distclean
	rm -rf $(BR_DIR)

.PHONY: show
show:
	@ls -lh $(IMAGES_DIR) || true

.PHONY: qemu
qemu:
	qemu-system-x86_64 \
		-m 1024 \
		-nographic \
		-kernel $(OUT_DIR)/images/bzImage \
		-append "root=PARTLABEL=rootfs.A rootwait rw console=tty0 console=ttyS0,115200 rauc.slot=A" \
		-nic user,model=e1000 \
		-drive file=$(OUT_DIR)/images/myfw.img,format=raw
