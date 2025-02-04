# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Automatically monitor system logs and mail security violations"
# Seems that the project has been discontinued by CISCO?
HOMEPAGE="https://sourceforge.net/projects/sentrytools/"
SRC_URI="mirror://gentoo/${P}.tar.gz"
S="${WORKDIR}"/logcheck-${PV}

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm ~mips ~ppc ~s390 sparc x86"
IUSE="selinux"

RDEPEND="
	virtual/mailx
	selinux? ( sec-policy/selinux-logsentry )
"

# compile and install mixed in the package makefile"
src_compile() { :; }

src_install() {
	dodir /usr/bin /var/tmp/logcheck /etc/logcheck

	cp systems/linux/logcheck.sh{,.orig} || die

	sed -i \
		-e 's:/usr/local/bin:/usr/bin:' \
		-e 's:/usr/local/etc:/etc/logcheck:' \
		-e 's:/etc/logcheck/tmp:/var/tmp/logcheck:' \
		systems/linux/logcheck.sh || \
			die "sed logcheck.sh failed"
	sed -i \
		-e "s:/usr/local/bin:${D}/usr/bin:" \
		-e "s:/usr/local/etc:${D}/etc/logcheck:" \
		-e "s:/etc/logcheck/tmp:/var/tmp/logcheck:" \
		-e "s:\$(CC):& \$(LDFLAGS):" \
		Makefile || die "sed Makefile failed"

	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" linux

	dodoc README* CHANGES CREDITS
	dodoc systems/linux/README.*

	cat <<- EOF > "${S}"/logsentry.cron || die
	#!/bin/sh
	#
	# Uncomment the following if you want
	# logsentry (logcheck) to run hourly
	#
	# this is part of the logsentry package
	#
	#

	#/bin/sh /etc/logcheck/logcheck.sh
	EOF

	exeinto /etc/cron.hourly
	doexe logsentry.cron
}

pkg_postinst() {
	elog
	elog "Uncomment the logcheck line in /etc/cron.hourly/logsentry.cron,"
	elog "or add directly to root's crontab"
	elog
}
