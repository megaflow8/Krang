# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome.org meson xdg

DESCRIPTION="Recommendation app data for GNOME"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-app-list"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
