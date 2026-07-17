# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome.org gnome2-utils meson systemd xdg

DESCRIPTION="Backend implementation for xdg-desktop-portal using GNOME"
HOMEPAGE="https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-libs/glib:2
	>=gnome-base/gsettings-desktop-schemas-50
	gnome-base/gnome-desktop:4=
	>=gui-libs/libadwaita-1.9:1
	media-libs/fontconfig
	sys-apps/dbus
	>=sys-apps/xdg-desktop-portal-1.19.1
	>=sys-apps/xdg-desktop-portal-gtk-1.14.0
	>=gui-libs/gtk-4.17.1:4[wayland]
	dev-libs/wayland
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-util/gdbus-codegen-2.80.5-r1
	sys-devel/gettext
	virtual/pkgconfig
	dev-util/wayland-scanner
"

src_configure() {
	local emesonargs=(
		-Dsystemduserunitdir="$(systemd_get_userunitdir)"
	)

	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
