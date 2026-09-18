# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

inherit cargo rust-toolchain toolchain-funcs

DESCRIPTION="GStreamer GTK 4 sink element"
HOMEPAGE="
	https://lib.rs/crates/gst-plugin-gtk4
	https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs/
"
SRC_URI="
	https://crates.io/api/v1/crates/${PN}/${PV}/download
		-> ${P}.crate
	https://binhost.h97i.org/Crates/gst-plugin-gtk4-0.15.2-crates.tar.xz
	${CARGO_CRATE_URIS}
"

LICENSE="MPL-2.0"
# Dependent crate licenses
LICENSE+=" Apache-2.0-with-LLVM-exceptions MIT Unicode-3.0"
SLOT="1.0"
KEYWORDS="amd64 arm64"
IUSE="+egl +gles2 opengl wayland +X" # Keep default IUSE mirrored with gst-plugins-base

DEPEND="
	dev-libs/glib
	>=gui-libs/gtk-4.16:4
	>=media-libs/gstreamer-1.24:1.0
	>=media-libs/gst-plugins-base-1.24:${SLOT}[egl=,gles2=,opengl=,wayland=,X=]
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	dev-util/cargo-c
"

QA_FLAGS_IGNORED="usr/lib.*/gstreamer-1.0/libgstgtk4.so"

src_configure() {
	local myfeatures=(
		# match that with gtk dep above, we don't really care to support
		# older versions here
		gtk_v4_16
	)

	# see https://github.com/GStreamer/gst-plugins-rs/blob/main/meson.build
	local gl_winsys=$(
		$(tc-getPKG_CONFIG) --variable=gl_winsys gstreamer-gl-1.0 || die
	)
	if has wayland ${gl_winsys}; then
		myfeatures+=( waylandegl )
	fi
	if has x11 ${gl_winsys}; then
		if has egl ${gl_winsys}; then
			myfeatures+=( x11egl )
		fi
		if has glx ${gl_winsys}; then
			myfeatures+=( x11glx )
		fi
	fi

	CARGO_ARGS=(
		--library-type=cdylib
		--prefix="${EPREFIX}"/usr
		--libdir="${EPREFIX}/usr/$(get_libdir)"
		--target="$(rust_abi)"
		$(usev !debug '--release')
	)

	cargo_src_configure
}

src_compile() {
	cargo cbuild "${CARGO_ARGS[@]}" || die
}

src_test() {
	# no tests, cargo [c]test just rebuilds everything for no gain
	:
}

src_install() {
	cargo cinstall "${CARGO_ARGS[@]}" --destdir="${D}" || die
}
