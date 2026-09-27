# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop gnome.org gnome2-utils meson pam readme.gentoo-r1 systemd xdg

DESCRIPTION="GNOME Display Manager for managing graphical display servers and user logins"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gdm"

SRC_URI="${SRC_URI}
	branding? ( https://www.mail-archive.com/tango-artists@lists.freedesktop.org/msg00043/tango-gentoo-v1.1.tar.gz )
"

LICENSE="
	GPL-2+
	branding? ( CC-BY-SA-4.0 )
"

SLOT="0"

KEYWORDS="~amd64 ~x86"

IUSE="audit debug branding fprint plymouth selinux systemd test video_cards_nvidia +X"

RESTRICT="!test? ( test )"
REQUIRED_USE="^^ ( systemd )"

# dconf, dbus and g-s-d are needed at install time for dconf update
# keyutils is automagic dep that makes autologin unlock login keyring
# when all the passwords match (disk encryption, user pw and login keyring)
# dbus-run-session used at runtime.
COMMON_DEPEND="
	>=dev-libs/libgudev-232:=
	>=dev-libs/glib-2.68:2
	>=dev-libs/json-glib-1.2.0
	>=sys-apps/accountsservice-0.6.35:=
	sys-auth/polkit
	sys-apps/keyutils:=
	selinux? ( sys-libs/libselinux )

	X? ( x11-libs/libXau )

	systemd? ( >=sys-apps/systemd-257:0=[pam] )

	plymouth? ( sys-boot/plymouth )
	audit? ( sys-process/audit )

	sys-libs/pam
	sys-auth/pambase[systemd?]

	>=gnome-base/dconf-0.20
	>=gnome-base/gnome-settings-daemon-3.1.4
	gnome-base/gsettings-desktop-schemas
	sys-apps/dbus

	>=x11-misc/xdg-utils-1.0.2-r3

	>=dev-libs/gobject-introspection-1.82.0-r2:=
"
# XXX: These deps are from session and desktop files in data/ directory
# fprintd is used via dbus by gdm-fingerprint-extension
RDEPEND="${COMMON_DEPEND}
	acct-group/gdm
	acct-user/gdm
	>=gnome-base/gnome-shell-50

	fprint? ( sys-auth/fprintd[pam] )

	systemd? (
		video_cards_nvidia? (
			x11-drivers/nvidia-drivers
			sys-apps/acl
		)
	)
	X? ( x11-apps/xhost )
"
DEPEND="${COMMON_DEPEND}
"
BDEPEND="
	dev-util/gdbus-codegen
	dev-util/glib-utils
	dev-util/itstool
	>=gnome-base/dconf-0.20
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	test? ( >=dev-libs/check-0.9.4 )
"

DOC_CONTENTS="
	To start GDM at boot with systemd, run:\n
	# systemctl enable gdm.service\n
	\n
	For passwordless login to unlock your keyring, you need to install
	sys-auth/pambase with USE=gnome-keyring and set an empty password
	on your keyring. Use app-crypt/seahorse for that.\n
	\n
	You may need to install app-crypt/coolkey and sys-auth/pam_pkcs11
	for smartcard support
"

src_prepare() {
	default

	# Show logo when branding is enabled
	use branding && eapply "${FILESDIR}/${PN}-3.30.3-logo.patch"
	eapply "${FILESDIR}/gdm-pam-openrc.patch"
}

src_configure() {
	local emesonargs=(
		--localstatedir /var

		-Ddefault-pam-config=exherbo
		-Dgdm-xsession=true
		-Dgroup=gdm
		$(meson_feature audit libaudit)
		-Dlogind-provider=systemd
		-Dpam-mod-dir=$(getpam_mod_dir)
		$(meson_feature plymouth)
		-Drun-dir=/run/gdm
		$(meson_feature selinux)
		$(meson_use systemd systemd-journal)
		-Dinitial-vt=1
		-Dsystemdsystemunitdir="$(systemd_get_systemunitdir)"
		-Dsystemduserunitdir="$(systemd_get_userunitdir)"
		)
	meson_src_configure
}

src_install() {
	meson_src_install

	# Ensure that gdm-greeter-XXX dynamic users have the needed
	# permissions on nvidia systems, bug #973590
	if use systemd && use video_cards_nvidia; then
		insinto /usr/lib/systemd/system/gdm.service.d
		doins "${FILESDIR}/90-nvidia-acl.conf"
	fi

	# install XDG_DATA_DIRS gdm changes
	echo 'XDG_DATA_DIRS="/usr/share/gdm"' > 99xdg-gdm
	doenvd 99xdg-gdm

	use branding && newicon "${WORKDIR}/tango-gentoo-v1.1/scalable/gentoo.svg" gentoo-gdm.svg

	readme.gentoo_create_doc
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update

	local d ret

	# bug #669146; gdm may crash if /var/lib/gdm subdirs are not owned by gdm:gdm
	ret=0
	ebegin "Fixing ${EROOT}/var/lib/gdm ownership"
	chown --no-dereference gdm:gdm "${EROOT}/var/lib/gdm" || ret=1
	for d in "${EROOT}/var/lib/gdm/"{.cache,.color,.config,.dbus,.local}; do
		[[ ! -e "${d}" ]] || chown --no-dereference -R gdm:gdm "${d}" || ret=1
	done
	eend ${ret}

	systemd_reenable gdm.service
	readme.gentoo_print_elog

}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
