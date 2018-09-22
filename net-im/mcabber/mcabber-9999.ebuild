# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic mercurial

DESCRIPTION="A small Jabber console client with various features, like MUC, SSL, PGP"
HOMEPAGE="http://mcabber.com/"
EHG_REPO_URI="https://bitbucket.org/McKael/mcabber"
EHG_CHECKOUT_DIR="${WORKDIR}"
EHG_BOOTSTRAP="autogen.sh"
S="${WORKDIR}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE="aspell crypt idn otr spell ssl vim-syntax"

LANGS="cs de fr it nl pl ru uk"
# localized help versions are installed only, when L10N var is set
for i in ${LANGS}; do
	IUSE="${IUSE} l10n_${i}"
done;

RDEPEND="crypt? ( >=app-crypt/gpgme-1.0.0 )
	otr? ( >=net-libs/libotr-3.1.0 )
	aspell? ( app-text/aspell )
	vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )
	idn? ( net-dns/libidn  )
	spell? ( app-text/enchant )
	dev-libs/glib:2
	net-libs/libnsl:0=
	sys-libs/ncurses:0=
	>=net-libs/loudmouth-1.4.3-r1[ssl?]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS=( AUTHORS ChangeLog NEWS README TODO mcabberrc.example doc/README_PGP.txt )

pkg_setup() {
	if use aspell && use spell; then
		ewarn "NOTE: You have both USE flags 'aspell' and 'spell' enabled, enchant (USE flag 'spell') will be preferred."
	fi
}

src_configure() {
	econf \
		--enable-modules \
		$(use_enable crypt gpgme) \
		$(use_enable otr) \
		$(use_enable aspell) \
		$(use_enable spell enchant) \
		$(use_with idn libidn)
}

src_install() {
	default

	# clean unneeded language documentation
	for i in ${LANGS}; do
		use l10n_${i} || rm -rf "${ED}"/usr/share/${PN}/help/${i}
	done

	# contrib themes
	insinto /usr/share/${PN}/themes
	doins "${S}"/contrib/themes/*

	# contrib generic scripts
	exeinto /usr/share/${PN}/scripts
	doexe "${S}"/contrib/*.{pl,py}

	# contrib event scripts
	exeinto /usr/share/${PN}/scripts/events
	doexe "${S}"/contrib/events/*

	if use vim-syntax; then
		cd contrib/vim/ || die

		insinto /usr/share/vim/vimfiles/syntax
		doins mcabber_log-syntax.vim

		insinto /usr/share/vim/vimfiles/ftdetect
		doins mcabber_log-ftdetect.vim
	fi
}

pkg_postinst() {
	elog
	elog "MCabber requires you to create a subdirectory .mcabber in your home"
	elog "directory and to place a configuration file there."
	elog "An example mcabberrc was installed as part of the documentation."
	elog "To create a new mcabberrc based on the example mcabberrc, execute the"
	elog "following commands:"
	elog
	elog "  mkdir -p ~/.mcabber"
	elog "  bzcat ${EROOT}usr/share/doc/${PF}/mcabberrc.example.bz2 >~/.mcabber/mcabberrc"
	elog
	elog "Then edit ~/.mcabber/mcabberrc with your favorite editor."
	elog
	elog "See the CONFIGURATION FILE and FILES sections of the mcabber"
	elog "manual page (section 1) for more information."
	elog
	elog "From version 0.9.0 on, MCabber supports PGP encryption of messages."
	elog "See README_PGP.txt for details."
	echo
	einfo "Check out ${EROOT}usr/share/${PN} for contributed themes and event scripts."
	echo
}
