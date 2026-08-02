# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..15} )

inherit gnome.org gnome2-utils meson python-any-r1 virtualx xdg

DESCRIPTION="GNOME's main interface to configure various aspects of the desktop"
HOMEPAGE="https://apps.gnome.org/Settings"
SRC_URI+=" https://dev.gentoo.org/~mattst88/distfiles/${PN}-gentoo-logo.svg"
SRC_URI+=" https://dev.gentoo.org/~mattst88/distfiles/${PN}-gentoo-logo-dark.svg"
# Logo is CC-BY-SA-2.5
LICENSE="GPL-2+ CC-BY-SA-2.5"
SLOT="2"
KEYWORDS="~amd64"

IUSE="cups X debug +ibus +geolocation systemd test wayland networkmanager"
REQUIRED_USE="
	?? ( systemd )" 
RESTRICT="!test? ( test )"

DEPEND="
	x11-libs/gtk+:3
	>=net-libs/gnome-online-accounts-3.51.0:=
	>=media-libs/libpulse-2.0[glib]
	>=gui-libs/gtk-4.17.1:4[wayland]
	>=gui-libs/libadwaita-1.8_alpha:1
	>=sys-apps/accountsservice-23.11.69
	>=x11-misc/colord-0.1.34:0=
	>=x11-libs/gdk-pixbuf-2.23.0:2
	>=dev-libs/glib-2.76.6:2
	gnome-base/gnome-desktop:4=
	>=gnome-base/gnome-settings-daemon-50
	>=gnome-base/gsettings-desktop-schemas-50
	dev-libs/libxml2:2=
	>=sys-power/upower-1.90.6:=
	>=dev-libs/libgudev-232
	media-libs/libepoxy
	>=app-crypt/gcr-4.1.0
	>=dev-libs/libpwquality-1.2.2
	>=sys-auth/polkit-0.114
	cups? (
		>=net-print/cups-1.7[dbus]
		>=net-fs/samba-4.0.0[client]
	)
	ibus? ( >=app-i18n/ibus-1.5.2 )
		>=net-libs/libnma-1.10.2
		>=net-misc/networkmanager-1.52.0[modemmanager]
		>=net-misc/modemmanager-0.7.990:=

	net-wireless/gnome-bluetooth:3=
	>=dev-libs/libwacom-1.4:=
	app-crypt/mit-krb5

	x11-libs/cairo[glib]
	>=x11-libs/colord-gtk-0.3.0:=
	media-libs/fontconfig
	gnome-base/libgtop:2=
	>=sys-fs/udisks-2.1.8:2
	app-crypt/libsecret
	net-libs/gnutls:=
	media-libs/gsound

	x11-libs/pango
"
RDEPEND="${DEPEND}
	media-libs/libcanberra[pulseaudio,sound(+)]
	systemd? ( >=sys-apps/systemd-31 )
	x11-themes/adwaita-icon-theme
	>=gnome-extra/gnome-color-manager-3.1.2
	cups? (
		app-admin/system-config-printer
		net-print/cups-pk-helper
	)
	>=gnome-extra/tecla-47.0
	dev-libs/libinput
"
PDEPEND=">=gnome-base/gnome-session-2.91.6-r1
	networkmanager? ( gnome-extra/nm-applet )" 

BDEPEND="${PYTHON_DEPS}
	dev-libs/libxslt
	app-text/docbook-xsl-stylesheets
	app-text/docbook-xml-dtd:4.2
	x11-base/xorg-proto
	dev-libs/libxml2:2
	>=dev-util/blueprint-compiler-0.17
	dev-util/gdbus-codegen
	dev-util/glib-utils
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	test? (
		$(python_gen_any_dep '
			dev-python/python-dbusmock[${PYTHON_USEDEP}]
		')
		x11-apps/setxkbmap
	)
"
PATCHES=(
	# Fix some absolute paths to be appropriate for Gentoo
	"${FILESDIR}/0005-Fix-absolute-paths-to-be-dependent-on-build-configur.patch"
	"${FILESDIR}/0002-exherbo-optionalise-cups-support.patch"
)
python_check_deps() {
	use test || return 0
	python_has_version "dev-python/python-dbusmock[${PYTHON_USEDEP}]"
}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	default
	xdg_environment_reset
	chmod a+x tests/network/test-network-panel.py tests/datetime/test-datetime.py || die
}

src_configure() {
	# -Werror=strict-aliasing
	# https://bugs.gentoo.org/889008

	local emesonargs=(
		$(meson_use cups)
		-Ddeprecated-declarations=disabled
		-Ddocumentation=true # manpage
		-Dlocation-services=$(usex geolocation enabled disabled)
		$(meson_use ibus)
		-Dprivileged_group=wheel
		-Dsnap=false
		$(meson_use test tests)
		-Dprofile=default
		-Dmalcontent=false # unpackaged
		-Ddistributor_logo=/usr/share/pixmaps/gnome-control-center-gentoo-logo.svg
		-Ddark_mode_distributor_logo=/usr/share/pixmaps/gnome-control-center-gentoo-logo-dark.svg
	)
	meson_src_configure
}

src_test() {
	# tests are fragile to long socket paths, bug #921583
	local -x TMPDIR=/tmp
	virtx meson_src_test
}

src_install() {
	meson_src_install
	insinto /usr/share/pixmaps
	doins "${DISTDIR}"/gnome-control-center-gentoo-logo.svg
	doins "${DISTDIR}"/gnome-control-center-gentoo-logo-dark.svg
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
