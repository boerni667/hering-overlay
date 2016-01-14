# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from mva overlay $

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit autotools eutils python-single-r1 systemd

DESCRIPTION="Allows you to easily put programs and users in a chrooted environment"
HOMEPAGE="http://olivier.sessink.nl/jailkit/"
SRC_URI="http://olivier.sessink.nl/${PN}/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="openrc systemd"

RDEPEND="systemd? ( sys-apps/systemd )
	openrc? ( sys-apps/openrc )"

src_prepare() {
	epatch \
		"${FILESDIR}/${P}-pyc.patch" \
		"${FILESDIR}/${P}-noshells.patch" \
		"${FILESDIR}/${P}-pythoninterpreter.patch"
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" PYTHONINTERPRETER=${PYTHON} install || die "emake install failed"
	if use openrc ;
	then 
		doinitd "${FILESDIR}/jailkit.initscript" ||  die "doinit install failed"
	fi
	if use systemd ;
	then
		systemd_dounit "${FILESDIR}/jailkit.service" || die "systemd_doinit install failed"
	fi

	python_fix_shebang "${ED}"
}

pkg_postinst() {
	ebegin "Updating /etc/shells"
	{ grep -v "^/usr/sbin/jk_chrootsh$" "${ROOT}"etc/shells; echo "/usr/sbin/jk_chrootsh"; } > "${T}"/shells
	mv -f "${T}"/shells "${ROOT}"etc/shells
	eend $?
}