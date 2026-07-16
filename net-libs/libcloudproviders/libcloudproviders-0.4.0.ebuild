# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome.org vala meson flag-o-matic

DESCRIPTION="DBus API that allows cloud storage sync clients to expose their services"
HOMEPAGE="https://gitlab.gnome.org/World/libcloudproviders"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc +introspection vala debug"
REQUIRED_USE="vala? ( introspection )"

DEPEND="
	>=dev-libs/glib-2.56:2
	introspection? ( >=dev-libs/gobject-introspection-1.82.0-r2 )"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-util/gdbus-codegen-2.80.5-r1
	dev-util/glib-utils
	virtual/pkgconfig
	doc? (
		dev-util/gi-docgen
		dev-libs/gobject-introspection
		)
	vala? ( $(vala_depend) )
"

src_prepare() {
	default
	use vala && vala_setup
}

src_configure() {
	append-cflags -Wno-typedef-redefinition
	append-cflags -Wno-deprecated-declarations
	append-cflags -Qunused-arguments
	if use debug; then
		EMESON_BUILDTYPE=debug
	fi
	local emesonargs=(
		$(meson_use doc documentation)
		-Dinstalled-tests=false
		$(meson_use introspection)
		$(meson_use vala vapigen)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
}
