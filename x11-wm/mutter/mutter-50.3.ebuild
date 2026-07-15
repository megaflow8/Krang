# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..15} )
inherit gnome.org gnome2-utils meson python-any-r1 udev xdg

DESCRIPTION="GNOME compositing window manager - Pure Wayland & Systemd Edition"
HOMEPAGE="https://mutter.gnome.org"
LICENSE="GPL-2+"

# Git logic vervangen door stabiele keywords en slotting
SLOT="0/$(($(ver_cut 1) - 32))"
KEYWORDS="~amd64"

IUSE="bash-completion debug gtk-doc input_devices_wacom +introspection screencast sysprof test udev +xwayland video_cards_nvidia"

REQUIRED_USE="
	gtk-doc? ( introspection )
	test? ( screencast )"
RESTRICT="!test? ( test )"

RDEPEND="
	>=media-libs/graphene-1.10.2[introspection?]
	x11-libs/gdk-pixbuf:2
	>=x11-libs/pango-1.46[introspection?]
	>=x11-libs/pixman-0.42
	>=dev-libs/fribidi-1.0.0
	>=gnome-base/gsettings-desktop-schemas-47_beta[introspection?]
	>=dev-libs/glib-2.81.1:2
	gnome-base/gnome-settings-daemon
	>=x11-libs/libxkbcommon-1.8.0
	>=app-accessibility/at-spi2-core-2.46:2[introspection?]
	sys-apps/dbus
	>=x11-misc/colord-1.4.5:=
	>=media-libs/lcms-2.6:2
	>=media-libs/harfbuzz-2.6.0:=
	>=dev-libs/libei-1.3.901
	>=media-libs/libdisplay-info-0.2:=
	>=media-libs/libcanberra-0.26
	media-libs/libglvnd
	>=dev-libs/wayland-1.23.0
	>=dev-libs/wayland-protocols-1.41
	>=x11-libs/libdrm-2.4.118
	media-libs/mesa[gbm(+)]
	>=dev-libs/libinput-1.27.0:=
	sys-apps/systemd
	media-libs/glycin:2

	udev? (
		>=virtual/libudev-232-r1:=
		>=dev-libs/libgudev-238
	)
	xwayland? ( >=x11-base/xwayland-23.2.1[libei(+)] )
	video_cards_nvidia? ( gui-libs/egl-wayland )
	input_devices_wacom? ( >=dev-libs/libwacom-0.13:= )
	screencast? ( >=media-video/pipewire-1.2.0:= )
	introspection? ( >=dev-libs/gobject-introspection-1.82.0-r2:= )
	sysprof? ( >=dev-util/sysprof-capture-3.40.1:4 >=dev-util/sysprof-3.46.0 )
"

DEPEND="${RDEPEND}
	sysprof? ( >=dev-util/sysprof-common-3.38.0 )
"

BDEPEND="
	dev-util/wayland-scanner
	>=dev-util/gdbus-codegen-2.80.5-r1
	dev-util/glib-utils
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	>=sys-kernel/linux-headers-4.4
	x11-libs/libxcvt
	gtk-doc? ( >=dev-util/gi-docgen-2021.1 )
	test? (
		${PYTHON_DEPS}
		$(python_gen_any_dep '
			>=dev-python/python-dbusmock-0.28[${PYTHON_USEDEP}]
		')
		app-text/docbook-xml-dtd:4.5
	)
	bash-completion? (
		app-shells/bash-completion
		${PYTHON_DEPS}
		$(python_gen_any_dep '
			dev-python/argcomplete[${PYTHON_USEDEP}]
		')
	)
"

python_check_deps() {
	if use test; then
		python_has_version ">=dev-python/python-dbusmock-0.28[${PYTHON_USEDEP}]"
	fi
	if use bash-completion; then
		python_has_version dev-python/argcomplete[${PYTHON_USEDEP}]
	fi
}

src_configure() {
	use debug && EMESON_BUILDTYPE=debug

	local emesonargs=(
		-Dgles2=true
		-Dlogind=true
		-Dsystemd=true
		-Dnative_backend=true
		-Dsound_player=true
		-Dstartup_notification=false
		-Dlibgnome_desktop=false
		-Dkvm_tests=false
		-Dtty_tests=false
		-Dinstalled_tests=false

		$(meson_use xwayland)
		$(meson_use screencast remote_desktop)
		$(meson_use udev)
		-Dudev_dir=$(get_udevdir)
		$(meson_use input_devices_wacom libwacom)
		$(meson_use introspection)
		$(meson_use gtk-doc docs)
		$(meson_use test cogl_tests)
		$(meson_use test clutter_tests)
		$(meson_use test mutter_tests)
		$(meson_feature test tests)
		$(meson_use sysprof profiler)
		$(meson_use bash-completion bash_completion)
	)

	# NVIDIA switches blijven dynamisch via de USE-vlag functioneren
	if use video_cards_nvidia; then
		emesonargs+=(
			-Degl_device=true
			-Dwayland_eglstream=true
		)
	else
		emesonargs+=(
			-Degl_device=false
			-Dwayland_eglstream=false
		)
	fi

	meson_src_configure
}

src_test() {
	gnome2_environment_reset
	export XDG_DATA_DIRS="${EPREFIX}"/usr/share
	glib-compile-schemas "${BUILD_DIR}"/data
	GSETTINGS_SCHEMA_DIR="${BUILD_DIR}"/data meson_src_test
}

pkg_postinst() {
	use udev && udev_reload
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	use udev && udev_reload
	xdg_pkg_postrm
	gnome2_schemas_update
}
