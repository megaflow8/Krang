# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Web-based administration interface for Unix systems"
HOMEPAGE="https://www.webmin.com/"
SRC_URI="https://www.webmin.com/download/webmin-${PV}.tar.gz"

S="${WORKDIR}/webmin-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="ssl"

RDEPEND="
	dev-lang/perl
	dev-perl/IO-Tty
	ssl? ( dev-perl/Net-SSLeay )
"

src_install() {
	# Installeer alle Webmin-bestanden in /usr/libexec/webmin
	dodir /usr/libexec/webmin
	cp -r . "${ED}/usr/libexec/webmin" || die "Copy failed"

	# Maak het configuratie- en log-pad aan
	dodir /etc/webmin
	dodir /var/webmin

	# Installeer de systemd service unit
	cat <<-EOF > "${T}/webmin.service"
		[Unit]
		Description=Webmin server daemon
		After=network.target

		[Service]
		Type=forking
		ExecStart=/etc/webmin/start
		ExecStop=/etc/webmin/stop
		ExecReload=/etc/webmin/reload
		PIDFile=/var/webmin/miniserv.pid

		[Install]
		WantedBy=multi-user.target
	EOF

	systemd_dounit "${T}/webmin.service"
}

pkg_postinst() {
	if [ ! -f "${EROOT}/etc/webmin/miniserv.conf" ]; then
		elog "Voer het setup-script uit om Webmin de eerste keer te configureren:"
		elog "  cd /usr/libexec/webmin && ./setup.sh /etc/webmin"
	fi
}
