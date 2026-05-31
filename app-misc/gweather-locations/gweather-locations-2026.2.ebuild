# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..14} )

inherit gnome.org gnome2-utils meson python-single-r1 xdg

DESCRIPTION="GWeather Locations Database"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gweather-locations"
SRC_URI="https://gitlab.gnome.org/GNOME/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"

RDEPEND="
	>=dev-libs/glib-2.76.0:2
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	${PYTHON_DEPS}
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default
	xdg_environment_reset
}

src_configure() {
	meson_src_configure
}

src_install() {
	#python_fix_shebang "${BUILD_DIR}/showtime"
	meson_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
