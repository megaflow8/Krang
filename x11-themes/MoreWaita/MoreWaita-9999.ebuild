# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg meson git-r3

DESCRIPTION="An expanded Adwaita-styled companion icon theme"
HOMEPAGE="https://github.com/somepaulo/MoreWaita"
EGIT_REPO_URI="https://github.com/somepaulo/MoreWaita"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""

# This ebuild does not install binaries
RESTRICT="binchecks strip"
RDEPEND="x11-themes/adwaita-icon-theme"
