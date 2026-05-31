# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"
RUST_MIN_VER=1.92.0

inherit cargo gnome.org gnome2 meson vala xdg

MY_PV=${PV/_/.}
MY_P=glycin-${MY_PV}

DESCRIPTION="Loaders for glycin clients (glycin crate or libglycin)"
HOMEPAGE="https://gitlab.gnome.org/GNOME/glycin/"
# upstream release tarballs are useless, as upstream is deliberately
# stripping glycin crate from them
SRC_URI="
	https://gitlab.gnome.org/GNOME/glycin/-/archive/${MY_PV}/${MY_P}.tar.bz2
	https://github.com/gentoo-crate-dist/glycin/releases/download/${MY_PV}/${MY_P}-crates.tar.xz
"
S=${WORKDIR}/${MY_P}

LICENSE="|| ( LGPL-2.1+ MPL-2.0 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD GPL-3+ IJG ISC
	LGPL-3+ MIT Unicode-3.0
	|| ( LGPL-2.1+ MPL-2.0 )
"
SLOT="2"
if [[ ${PV} != *_[ab]* ]]; then
	KEYWORDS="~amd64 ~arm64"
fi
IUSE="+introspection +vala test gtk"
REQUIRED_USE="vala? ( introspection )"
RESTRICT="!test? ( test )"
RDEPEND="
	>=dev-libs/glib-2.60:2
	>=media-libs/fontconfig-2.13.0:=
	media-libs/glycin-loaders:2
	>=media-libs/lcms-2.12:=
	sys-apps/bubblewrap
	>=sys-libs/libseccomp-2.5.0
"
DEPEND="${RDEPEND}"

BDEPEND="
	vala? ( $(vala_depend) )
	virtual/pkgconfig
"
QA_FLAGS_IGNORED="usr/lib64/libglycin-2*"

src_unpack() {
	cargo_src_unpack
}

src_prepare() {
	default
	use vala && vala_setup
}

src_configure() {
	local emesonargs=(
		-Dwerror=false
		-Dlibglycin=true
		$(meson_use vala vapi)
		-Dglycin-loaders=false
		$(meson_use introspection)
		$(meson_use gtk libglycin-gtk4)
		-Dglycin-thumbnailer=false
		-Dtests=$(usex test true false)
	)

	meson_src_configure
	ln -s "${CARGO_HOME}" "${BUILD_DIR}/cargo-home" || die
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
