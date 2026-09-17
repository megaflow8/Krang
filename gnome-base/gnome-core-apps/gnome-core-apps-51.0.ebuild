# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Sub-meta package for the core applications integrated with GNOME"
HOMEPAGE="https://www.gnome.org/"

S="${WORKDIR}"

LICENSE="metapackage"
SLOT="3.0"
KEYWORDS="~amd64"

IUSE="bluetooth cups"

DEPEND=""
RDEPEND="
	>=gnome-base/gnome-core-libs-${PV}

	>=gnome-base/gnome-session-${PV}
	>=gnome-base/gnome-settings-daemon-${PV}
	>=gnome-base/gnome-control-center-${PV}
	>=gnome-extra/gnome-color-manager-3.36.2

	>=app-crypt/gcr-4.4:4
	>=gnome-base/nautilus-${PV}
	>=gnome-base/gnome-keyring-${PV}
	>=gnome-extra/evolution-data-server-3.56
	>=net-libs/glib-networking-2.80.1
	>=gui-apps/gnome-console-${PV}

	>=x11-themes/adwaita-icon-theme-${PV}
	>=x11-themes/sound-theme-freedesktop-0.8
	bluetooth? ( >=net-wireless/gnome-bluetooth-47.2 )
	>=gnome-base/gnome-menus-3.38.1
	>=gnome-extra/gnome-app-list-2026.08
"
BDEPEND=""
