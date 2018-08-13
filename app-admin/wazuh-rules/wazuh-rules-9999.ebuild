
https://github.com/wazuh/wazuh-ruleset.git for live... 
https://github.com/wazuh/wazuh-ruleset/releases/tag/v3.4.0 
# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_6 )

inherit python-single-r1
# distutils-r1

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/wazuh/wazuh-ruleset.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/wazuh/wazuh-ruleset/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
fi

DESCRIPTION="An open-source exploitation framework dedicated to embedded devices"
HOMEPAGE="https://wazuh.com"
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


# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3

DESCRIPTION="All exploits from exploit-db.com"
HOMEPAGE="http://www.exploit-db.com/"
EGIT_REPO_URI="https://github.com/offensive-security/exploit-database"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}/disable-update.patch"
	eapply_user
}

src_install() {
	insinto /etc
	doins "${FILESDIR}/searchsploit_rc"

	insinto /usr/share/${PN}
	doins -r *

	fperms +x /usr/share/${PN}/searchsploit
	dosym "${EPREFIX}"/usr/share/${PN}/searchsploit /usr/bin/searchsploit
}
