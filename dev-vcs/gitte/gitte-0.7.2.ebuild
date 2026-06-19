# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
CRATES="
"
inherit cargo gnome2 meson xdg


DESCRIPTION="A GTK4/libadwaita Git client for the GNOME desktop"
HOMEPAGE="https://codeberg.org/ckruse/Gitte"
SRC_URI="https://codeberg.org/ckruse/Gitte/archive/${PV}.tar.gz"
SRC_URI+=" https://binhost.h97i.org/Crates/gitte-0.7.2-crates.tar.xz"

S=${WORKDIR}/gitte

RUST_MIN_VER="1.93"

LICENSE=""
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD CC0-1.0
	CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB
"

SLOT="0"

KEYWORDS="~amd64"

BDEPEND="
	gnome-base/dconf
	dev-libs/glib
	media-libs/graphene
	gui-libs/gtk
	gui-libs/libadwaita
	dev-libs/openssl
	x11-libs/pango
	app-arch/xz-utils
	virtual/zlib
"

DEPEND="
	x11-libs/cairo
	
"
RDEPEND+="
	dev-libs/libgit2
	net-libs/libssh2
"

QA_FLAGS_IGNORED="/usr/libexec/gitte/gitte-askpass /usr/bin/gitte"

src_configure() {
	local emesonargs=(
	-Dcargo-home=cargo_home
	)
	meson_src_configure
	ln -s "${CARGO_HOME}" "${BUILD_DIR}/cargo_home" || die
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
