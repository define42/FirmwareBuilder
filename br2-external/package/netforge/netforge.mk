################################################################################
#
# netforge
#
################################################################################

NETFORGE_VERSION = 1.0.2
NETFORGE_SOURCE = netforge_linux_amd64
NETFORGE_SITE = https://github.com/define42/NetForge/releases/download/v$(NETFORGE_VERSION)
NETFORGE_LICENSE = Apache-2.0

define NETFORGE_EXTRACT_CMDS
	cp $(NETFORGE_DL_DIR)/$(NETFORGE_SOURCE) $(@D)/netforge
endef

define NETFORGE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/netforge \
		$(TARGET_DIR)/usr/bin/netforge
	$(INSTALL) -D -m 0644 $(NETFORGE_PKGDIR)/netforge.default \
		$(TARGET_DIR)/etc/default/netforge
	$(INSTALL) -D -m 0644 $(NETFORGE_PKGDIR)/namespaces.json.example \
		$(TARGET_DIR)/etc/netforge/namespaces.json.example
	$(INSTALL) -d -m 0700 $(TARGET_DIR)/var/lib/netforge
endef

define NETFORGE_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(NETFORGE_PKGDIR)/S99netforge \
		$(TARGET_DIR)/etc/init.d/S99netforge
endef

$(eval $(generic-package))
