# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome.org meson

DESCRIPTION="GWeather Locations Database"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gweather-locations"
SRC_URI="https://gitlab.gnome.org/GNOME/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"

KEYWORDS="~amd64"

RDEPEND="
	>=dev-libs/glib-2.76.0:2
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"
