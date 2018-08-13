# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_6 )

inherit python-single-r1
# distutils-r1

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/threat9/routersploit.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/threat9/routersploit/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
fi

DESCRIPTION="An open-source exploitation framework dedicated to embedded devices"
HOMEPAGE="https://github.com/threat9/routersploit/wiki"
LICENSE="BSD"
SLOT="0"
IUSE="doc desktopicons bluetooth"

DEPEND=">=dev-python/future-0.16.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.9.1[${PYTHON_USEDEP}]
	>=dev-python/paramiko-1.16.0[${PYTHON_USEDEP}]
	>=dev-python/pysnmp-4.3.2[${PYTHON_USEDEP}]
	>=dev-python/pycryptodome-2.6.1[${PYTHON_USEDEP}]
	bluetooth? ( dev-python/bluepy )"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_prepare() {
	#do not compile
	rm -f Makefile
	eapply_user
}

src_install() {
	dodir /opt/${PN}
	insinto  /opt/${PN}
	doins -r routersploit/ rsf.py
	fperms +x /opt/${PN}/rsf.py
	dosym "${EPREFIX}"/opt/${PN}/rsf.py /usr/bin/rsf

	if use doc; then
		einstalldocs /usr/share/doc/${PN}/
		dodoc -r /{README.md,LICENSE}
	fi

	#FIXME: convert to desktop.eclass
	if use desktopicons; then
		dodir /usr/share/icons/${PN}/
		cp  ${FILES}/{routersploit.png,routersploit.svg}  /usr/share/icons/${PN}/
		dodir  /usr/share/applications/${PN}/
		cp ${FILES}*.desktop  /usr/share/applications/${PN}/
		fixperms +r +x /usr/share/applications/${PN}/*.desktop
	fi

}

# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools eutils fcaps flag-o-matic git-r3

DESCRIPTION="My TraceRoute, an Excellent network diagnostic tool"
HOMEPAGE="http://www.bitwizard.nl/mtr/"
EGIT_REPO_URI="https://github.com/traviscross/mtr.git"
SRC_URI="mirror://gentoo/gtk-2.0-for-mtr.m4.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="gtk ipv6 ncurses"

RDEPEND="
	gtk? (
		dev-libs/glib:2
		x11-libs/gtk+:2
	)
	ncurses? ( sys-libs/ncurses:0= )
"
DEPEND="
	${RDEPEND}
	sys-devel/autoconf
	virtual/pkgconfig
"

DOCS=( AUTHORS FORMATS NEWS README SECURITY TODO )
FILECAPS=( cap_net_raw usr/sbin/mtr-packet )
PATCHES=(
	"${FILESDIR}"/${PN}-0.88-tinfo.patch
)

src_unpack() {
	git-r3_src_unpack
	unpack ${A}
}

src_prepare() {
	# Keep this comment and following mv, even in case ebuild does not need
	# it: kept gtk-2.0.m4 in SRC_URI but you'll have to mv it before autoreconf
	mv "${WORKDIR}"/gtk-2.0-for-mtr.m4 gtk-2.0.m4 || die #222909

	default

	AT_M4DIR="." eautoreconf
}

src_configure() {
	# In the source's configure script -lresolv is commented out. Apparently it
	# is still needed for 64-bit MacOS.
	[[ ${CHOST} == *-darwin* ]] && append-libs -lresolv
	econf \
		$(use_enable ipv6) \
		$(use_with gtk) \
		$(use_with ncurses)
}

pkg_postinst() {
	fcaps_pkg_postinst

	if use prefix && [[ ${CHOST} == *-darwin* ]] ; then
		ewarn "mtr needs root privileges to run.  To grant them:"
		ewarn " % sudo chown root ${EPREFIX}/usr/sbin/mtr"
		ewarn " % sudo chmod u+s ${EPREFIX}/usr/sbin/mtr"
	fi
}
