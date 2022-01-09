SECTION="NetPing modules"
CATEGORY="Base"
TITLE="EPIC OWRT-WEB-digital-outs"

PKG_NAME="OWRT-WEB-digital-outs"
PKG_VERSION=0.1
PKG_RELEASE=1
PKG_DEPENDS=OWRT-digital-outs

MODULE_NAME=owrt_web_digital_outs
MODULE_FILES_DIR=/usr/lib/lua/luci/
STATIC_FILES_DIR=/www/luci-static/resources/

.PHONY: all install

all: install

install:

	cp -r luasrc/* $(MODULE_FILES_DIR)
	cp -r htdocs/luci-static/resources/* $(STATIC_FILES_DIR)

clean:

	rm -r $(MODULE_FILES_DIR)controller/$(MODULE_NAME)
	rm -r $(MODULE_FILES_DIR)model/$(MODULE_NAME)
	rm -r $(MODULE_FILES_DIR)model/cbi/$(MODULE_NAME)
	rm -r $(MODULE_FILES_DIR)view/$(MODULE_NAME)
	rm $(MODULE_FILES_DIR)i18n/$(MODULE_NAME).*.lmo
	rm -r $(STATIC_FILES_DIR)$(MODULE_NAME)
