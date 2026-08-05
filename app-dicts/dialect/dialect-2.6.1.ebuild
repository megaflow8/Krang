# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..15} )
inherit meson xdg python-single-r1

DESCRIPTION="A translation app for GNOME"
HOMEPAGE="https://github.com/dialect-app/dialect"
SRC_URI="
	https://github.com/dialect-app/dialect/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/dialect-app/po -> ${P}-po.tar.gz
"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
IUSE="${PYTHON_IUSE}"

DEPEND="
	${PYTHON_DEPS}
	dev-libs/glib:2
	>=dev-libs/gobject-introspection-1.35.0
	>=media-libs/gstreamer-1.18
	>=gui-libs/gtk-4.17.5:4
	>=gui-libs/libadwaita-1.7:1
	net-libs/libsoup:3.0
	app-text/libspelling:1
	>=dev-python/pygobject-3.51:3
"
RDEPEND="
	${DEPEND}
	$(python_gen_cond_dep '
		>=dev-python/beautifulsoup4-4.14.3[${PYTHON_USEDEP}]
		>=dev-python/certifi-2026.4.22[${PYTHON_USEDEP}]
		>=dev-python/charset-normalizer-3.4.7[${PYTHON_USEDEP}]
		>=dev-python/click-8.1.8[${PYTHON_USEDEP}]
		>=dev-python/colorama-0.4.6[${PYTHON_USEDEP}]
		>=dev-python/gtts-2.5.4[${PYTHON_USEDEP}]
		>=dev-python/idna-3.14[${PYTHON_USEDEP}]
		>=dev-python/requests-2.33.1[${PYTHON_USEDEP}]
		>=dev-python/soupsieve-2.8.3[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.15.0[${PYTHON_USEDEP}]
		>=dev-python/urllib3-2.7.0[${PYTHON_USEDEP}]
	')
"

BDEPEND="
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=()
	-Dprofile=default
	meson_src_configure
}
src_prepare() {
	default
	
	# Verplaats de losse vertalingen naar de 'po' map die Meson verwacht
	rm -rf po || die
	mv "${WORKDIR}/po-${PV}" "${S}/po" || die
}
