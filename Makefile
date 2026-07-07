APP            := spectral
VERSION        := 1.1.0
BUILD          := build/release
PKGROOT        := $(APP)_$(VERSION)
DMG_STAGING    := dmg_staging

UNAME_S        := $(shell uname -s)
UNAME_M        := $(shell uname -m)
LAZBUILD       := lazbuild
TARGETOS       := $(shell fpc -iTO)
TARGETCPU      := $(shell fpc -iTP)
BUILDDIR       := $(BUILD)/$(TARGETOS)-$(TARGETCPU)

# ----------------------------
# SeaBreeze library (built from source, then bundled into the package)
# ----------------------------
# Cloned as a sibling directory - same convention as the Pascal deps
# (bgrabitmap etc.) cloned by the CI workflow.
SEABREEZE_REPO   := https://github.com/ovidiopr/SeaBreeze.git
SEABREEZE_SRC    := ../SeaBreeze
SEABREEZE_LIBDIR := $(SEABREEZE_SRC)/lib

ifeq ($(UNAME_S),Darwin)
  SEABREEZE_LIB := libseabreeze.dylib
else
  SEABREEZE_LIB := libseabreeze.so
endif

# ----------------------------
# Architecture detection (Linux)
# ----------------------------
ifeq ($(UNAME_M),x86_64)
  DEB_ARCH := amd64
endif
ifeq ($(UNAME_M),i386)
  DEB_ARCH := i386
endif
ifeq ($(UNAME_M),i686)
  DEB_ARCH := i386
endif
ifeq ($(UNAME_M),armv7l)
  DEB_ARCH := armhf
endif
ifeq ($(UNAME_M),aarch64)
  DEB_ARCH := arm64
endif
DEB_ARCH ?= unknown

# ----------------------------
# Targets
# ----------------------------
.PHONY: all clean seabreeze build build_deb build_dmg package_deb package_dmg

all: build

clean:
	rm -rf $(BUILD) $(PKGROOT) $(DMG_STAGING) *.deb *.dmg

# ----------------------------
# SeaBreeze (native C/C++ library dependency)
# ----------------------------
# Clones (if not already present) and builds SeaBreeze via its own plain
# `make` (Linux/macOS only - see README: Windows normally uses Visual Studio
# instead, so a prebuilt SeaBreeze.dll is vendored for the Windows package).
seabreeze:
	@if [ ! -d "$(SEABREEZE_SRC)" ]; then \
		echo "Cloning SeaBreeze from $(SEABREEZE_REPO)..."; \
		git clone $(SEABREEZE_REPO) $(SEABREEZE_SRC); \
	fi
	@echo "Building SeaBreeze ($(SEABREEZE_LIB))..."
	$(MAKE) -C $(SEABREEZE_SRC) CXXFLAGS="$(CXXFLAGS)"
	@test -f "$(SEABREEZE_LIBDIR)/$(SEABREEZE_LIB)" || \
		{ echo "ERROR: $(SEABREEZE_LIB) not found in $(SEABREEZE_LIBDIR) after build"; exit 1; }

# ----------------------------
# Build (native)
# ----------------------------
# The app links against SeaBreeze, so it must exist before we compile.
build: seabreeze
	cd src/ && $(LAZBUILD) $(APP).lpi --build-mode=Release

# ----------------------------
# Linux Debian package (also used for Raspberry Pi / arm64)
# ----------------------------

build_deb: clean build package_deb

package_deb:
	@echo "Packaging Debian package for $(DEB_ARCH)"
	@test -f "$(BUILDDIR)/$(APP)" || \
		{ echo "ERROR: $(BUILDDIR)/$(APP) not found - run 'make build' (or build_deb) first"; exit 1; }
	@test -f "$(SEABREEZE_LIBDIR)/$(SEABREEZE_LIB)" || \
		{ echo "ERROR: $(SEABREEZE_LIB) not found - run 'make seabreeze' (or build_deb) first"; exit 1; }
	rm -rf $(PKGROOT)
	mkdir -p $(PKGROOT)/DEBIAN
	mkdir -p $(PKGROOT)/usr/bin
	mkdir -p $(PKGROOT)/usr/lib/$(APP)
	mkdir -p $(PKGROOT)/usr/share/applications
	mkdir -p $(PKGROOT)/etc/udev/rules.d

	# Install Binary
	cp $(BUILDDIR)/$(APP) $(PKGROOT)/usr/bin/
	chmod 755 $(PKGROOT)/usr/bin/$(APP)

	# Install SeaBreeze into an app-private lib dir (avoids clashing with any
	# system-wide libseabreeze the user may separately have installed) and
	# point the binary at it via rpath, so no ldconfig/system install is needed.
	cp $(SEABREEZE_LIBDIR)/$(SEABREEZE_LIB) $(PKGROOT)/usr/lib/$(APP)/
	chmod 755 $(PKGROOT)/usr/lib/$(APP)/$(SEABREEZE_LIB)
	@if command -v patchelf >/dev/null 2>&1; then \
		patchelf --set-rpath '$$ORIGIN/../lib/$(APP)' $(PKGROOT)/usr/bin/$(APP); \
	else \
		echo "WARNING: patchelf not found - binary will rely on /etc/ld.so.conf.d instead of rpath"; \
		mkdir -p $(PKGROOT)/etc/ld.so.conf.d; \
		echo "/usr/lib/$(APP)" > $(PKGROOT)/etc/ld.so.conf.d/$(APP).conf; \
	fi

	# Install udev Rules (for spectrometer permissions)
	cp 99-oceanoptics.rules $(PKGROOT)/etc/udev/rules.d/

	# Control and Postinst (postinst should run "ldconfig" - needed if the
	# ld.so.conf.d fallback above was used)
	sed "s/@ARCH@/$(DEB_ARCH)/" debian/control > $(PKGROOT)/DEBIAN/control
	cp debian/postinst $(PKGROOT)/DEBIAN/
	chmod 755 $(PKGROOT)/DEBIAN/postinst

	# Desktop entry
	cp debian/$(APP).desktop $(PKGROOT)/usr/share/applications/

	# Icons (SVG + PNG fallbacks)
	mkdir -p $(PKGROOT)/usr/share/icons/hicolor/scalable/apps
	mkdir -p $(PKGROOT)/usr/share/icons/hicolor/256x256/apps
	mkdir -p $(PKGROOT)/usr/share/icons/hicolor/128x128/apps
	mkdir -p $(PKGROOT)/usr/share/icons/hicolor/64x64/apps

	cp icons/$(APP)/$(APP).svg $(PKGROOT)/usr/share/icons/hicolor/scalable/apps/$(APP).svg
	cp icons/$(APP)/$(APP)_256.png $(PKGROOT)/usr/share/icons/hicolor/256x256/apps/$(APP).png
	cp icons/$(APP)/$(APP)_128.png $(PKGROOT)/usr/share/icons/hicolor/128x128/apps/$(APP).png
	cp icons/$(APP)/$(APP)_64.png $(PKGROOT)/usr/share/icons/hicolor/64x64/apps/$(APP).png

	fakeroot dpkg-deb --build $(PKGROOT)
	mv $(PKGROOT).deb $(APP)_$(VERSION)_$(DEB_ARCH).deb

# ----------------------------
# macOS DMG package
# ----------------------------

build_dmg: clean build package_dmg

package_dmg:
	@echo "Packaging macOS DMG with icons..."
	@test -f "$(BUILDDIR)/$(APP)" || \
		{ echo "ERROR: $(BUILDDIR)/$(APP) not found - run 'make build' (or build_dmg) first"; exit 1; }
	@test -f "$(SEABREEZE_LIBDIR)/$(SEABREEZE_LIB)" || \
		{ echo "ERROR: $(SEABREEZE_LIB) not found - run 'make seabreeze' (or build_dmg) first"; exit 1; }
	$(eval STAGING := $(DMG_STAGING))
	$(eval APP_BUNDLE := $(STAGING)/$(APP).app)
	rm -rf $(STAGING)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources

	# Copy Binary
	cp $(BUILDDIR)/$(APP) $(APP_BUNDLE)/Contents/MacOS/$(APP)
	chmod 755 $(APP_BUNDLE)/Contents/MacOS/$(APP)

	# Copy the library
	cp $(SEABREEZE_LIBDIR)/$(SEABREEZE_LIB) $(APP_BUNDLE)/Contents/MacOS/
	install_name_tool -id "@executable_path/../MacOS/$(SEABREEZE_LIB)" $(APP_BUNDLE)/Contents/MacOS/$(SEABREEZE_LIB)
	codesign -s - --force $(APP_BUNDLE)/Contents/MacOS/$(SEABREEZE_LIB)

	# Copy the Icon into the App Bundle
	cp icons/spectral.icns $(APP_BUNDLE)/Contents/Resources/spectral.icns

	# Generate Info.plist (Added CFBundleIconFile)
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(APP_BUNDLE)/Contents/Info.plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<plist version="1.0"><dict>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '  <key>CFBundleExecutable</key><string>$(APP)</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '  <key>CFBundleIdentifier</key><string>com.spectral.app</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '  <key>CFBundleName</key><string>Spectral</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '  <key>CFBundleIconFile</key><string>spectral.icns</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '  <key>CFBundleVersion</key><string>$(VERSION)</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '  <key>CFBundlePackageType</key><string>APPL</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '  <key>LSMinimumSystemVersion</key><string>10.12</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '</dict></plist>' >> $(APP_BUNDLE)/Contents/Info.plist

	# Prepare Volume Icon (The icon of the DMG disk itself)
	cp icons/spectral.icns $(STAGING)/.VolumeIcon.icns
	# Set the 'Custom Icon' bit on the staging folder
	SetFile -a C $(STAGING)

	# Symbolic link for drag-and-drop
	ln -s /Applications $(STAGING)/Applications

	# Create the DMG
	hdiutil create -volname "$(APP) $(VERSION)" -srcfolder $(STAGING) -ov -format UDZO $(APP)_$(VERSION)_$(TARGETCPU).dmg

	rm -rf $(STAGING)
	@echo "macOS DMG created successfully."
