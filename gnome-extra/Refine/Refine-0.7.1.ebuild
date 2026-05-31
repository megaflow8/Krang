# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2-utils meson xdg

DESCRIPTION="Tweak various aspects of GNOME"
HOMEPAGE="https://gitlab.gnome.org/TheEvilSkeleton/Refine"
SRC_URI="https://gitlab.gnome.org/TheEvilSkeleton/Refine/-/archive/${PV}/Refine-${PV}.tar.bz2"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~x86"
IUSE=""

src_prepare() {
	default
	xdg_environment_reset
}

src_configure() {
	meson_src_configure
}

src_install() {
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
