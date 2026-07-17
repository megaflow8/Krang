# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome.org gnome2-utils meson vala

DESCRIPTION="Disk usage browser for GNOME"
HOMEPAGE="https://apps.gnome.org/Baobab/"

LICENSE="GPL-2+ FDL-1.1+"
SLOT="0"
KEYWORDS="~amd64"

PATCHES=(
	"${FILESDIR}/0001-Scanner-Initialize-root-results-as-empty.patch"
)

RDEPEND="
	>=dev-libs/glib-2.44:2
	>=gui-libs/gtk-4.15.1:4
	>=gui-libs/libadwaita-1.8:1
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(vala_depend)
	>=gui-libs/libadwaita-1.8:1[vala]
	dev-util/itstool
	>=sys-devel/gettext-0.21
	virtual/pkgconfig
"

src_prepare() {
	default
	vala_setup
}

pkg_postinst() {
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_schemas_update
}
