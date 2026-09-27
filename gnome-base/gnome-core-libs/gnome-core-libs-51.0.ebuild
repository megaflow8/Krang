# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Sub-meta package for the core libraries of GNOME"
HOMEPAGE="https://www.gnome.org/"

S="${WORKDIR}"

LICENSE="metapackage"
SLOT="3.0"
KEYWORDS="~amd64 ~arm arm64 ~loong ~ppc64 ~riscv x86"

IUSE="cups python gtk"

# Note to developers:
# This is a wrapper for the core libraries used by GNOME
DEPEND=""
RDEPEND="
	>=dev-libs/glib-2.90:2
	>=x11-libs/gdk-pixbuf-2.44.7:2
	>=x11-libs/pango-1.58
	>=x11-libs/gtk+-3.24.50:3[cups?]
	>=gui-libs/gtk-4.24:4[cups?]
	>=gui-libs/libadwaita-1.10:1
	>=app-accessibility/at-spi2-core-2.62:2
	>=media-libs/glycin-loaders-2.2.0
	>=media-libs/glycin-2.2.0
	>=gnome-base/librsvg-2.63
	>=gnome-base/gnome-desktop-${PV}:4

	>=gnome-base/gvfs-1.60
	>=gnome-base/dconf-${PV}

	>=media-libs/gstreamer-1.28:1.0
	>=media-libs/gst-plugins-base-1.28:1.0
	>=media-libs/gst-plugins-good-1.28:1.0

	python? ( >=dev-python/pygobject-3.56.0:3 )
"
BDEPEND=""
