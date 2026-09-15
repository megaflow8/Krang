# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="A lightweight, minimal AppStream metadata parser"
HOMEPAGE="https://gitlab.gnome.org/GNOME/ministream"
SRC_URI="https://gitlab.gnome.org/GNOME/ministream/-/archive/${PV}/ministream-${PV}.tar.bz2"

LICENSE="LGPL-2.1-or-later"
SLOT="0"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.0:2[introspection]
	dev-libs/gobject-introspection:=
	dev-libs/appstream:0=
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	dev-libs/libxml2
"

src_configure() {
	local emesonargs=(
		$(meson_use test tests)
	-Das-compare=disabled
	)
	meson_src_configure
}
