# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="suid, sgid file and directory checking"
HOMEPAGE="https://linukz.org/sxid.shtml https://github.com/taem/sxid"
SRC_URI="https://linukz.org/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="selinux"

RDEPEND="
	virtual/mailx
	selinux? ( sec-policy/selinux-sxid )
"

DOCS=( NEWS README docs/sxid.{conf,cron}.example )

src_prepare() {
	default
	# this is an admin application and really requires root to run correctly
	# we need to move the binary to the sbin directory
	sed -i 's/bindir/sbindir/g' source/Makefile.in || die
	sed -i -e 's/configure.in/configure.ac/g' Makefile || die
	eautoreconf
}

pkg_postinst() {
	elog "You will need to configure sxid.conf for your system using the manpage and example"
}
