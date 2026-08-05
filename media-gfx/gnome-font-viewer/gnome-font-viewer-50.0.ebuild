# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit gnome.org meson xdg

DESCRIPTION="Font viewer utility for GNOME"
HOMEPAGE="https://apps.gnome.org/FontViewer/"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=dev-libs/glib-2.56.0:2
	gui-libs/gtk:4
	gui-libs/libadwaita:1
	media-libs/harfbuzz:=
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	dev-libs/fribidi
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=()
	-Dprofile=default
	meson_src_configure
}
