BR_DIR  := $(CURDIR)/buildroot
BR_EXT  := $(CURDIR)/br2-external
OUT_DIR := $(CURDIR)/output
DL_DIR  := $(CURDIR)/dl

BR_ARGS = \
	BR2_EXTERNAL=$(BR_EXT) \
	BR2_DL_DIR=$(DL_DIR) \
	O=$(OUT_DIR)

.PHONY: all
all: build

.PHONY: defconfig
defconfig:
	$(MAKE) -C $(BR_DIR) $(BR_ARGS) myfw_x86_64_rauc_defconfig

.PHONY: menuconfig
menuconfig:
	$(MAKE) -C $(BR_DIR) $(BR_ARGS) menuconfig

.PHONY: build
build: defconfig
	$(MAKE) -C $(BR_DIR) $(BR_ARGS)

.PHONY: bundle
bundle:
	VERSION=$(VERSION) $(BR_EXT)/board/myfw/make-bundle.sh \
		$(OUT_DIR)/images \
		$(BR_EXT)/board/myfw

.PHONY: clean
clean:
	$(MAKE) -C $(BR_DIR) $(BR_ARGS) clean

.PHONY: distclean
distclean:
	rm -rf $(OUT_DIR)

.PHONY: show
show:
	@ls -lh $(OUT_DIR)/images || true
