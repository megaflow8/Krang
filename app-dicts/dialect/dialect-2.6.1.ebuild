# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit meson xdg

DESCRIPTION="A translation app for GNOME"
HOMEPAGE="https://github.com/dialect-app/dialect"
SRC_URI="https://github.com/dialect-app/dialect/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-libs/glib:2
	>=dev-libs/gobject-introspection-1.35.0
	>=media-libs/gstreamer-1.18
	>=gui-libs/gtk-4.17.5:4
	>=gui-libs/libadwaita-1.7:1
	net-libs/libsoup:3.0
	app-text/libspelling:1
	>=dev-python/pygobject-3.51:3
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=()
	-Dprofile=default
	meson_src_configure
}
