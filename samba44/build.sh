#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
# Portions Copyright 2014 Ryan Blair
#
# Load support functions
. ../../lib/functions.sh
. ../../../lib/more-functions.sh #from epoxy-ips-bootstrap

PROG=samba      # App name
VER=4.4.7      # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=$PKGNAMESPACE/service/network/samba44 # Package name (e.g. library/foo)
SUMMARY="${PROG}44 - CIFS server and domain controller"
DESC="${SUMMARY}"         # Longer description, must be filled in
SHORTVER=$(shorten_to_majmin $VER)
PYTHON_SHORTVER=$(shorten_to_majmin ${PYTHONVER})

BUILD_DEPENDS_IPS="\
    system/library/mozilla-nss \
    library/nspr \
    system/library/security/libsasl \
    library/zlib \
    runtime/perl"
RUN_DEPENDS_IPS="${BUILD_DEPENDS_IPS}"

# reconfigure download to use a global site
MIRROR=ftp.samba.org

#use WAF instead of autoconf
CONFIGURE_CMD="/usr/bin/python buildtools/bin/waf configure ${MAKE_JOBS}"

# tried to configure similar to debian layout
BUILDARCH=64
CONFIGURE_OPTS_64="
    --prefix=$PREFIX/$PROG/$SHORTVER
    --with-configdir=/etc/samba
    --with-privatedir=/etc/samba/private
    --with-piddir=/var/run/samba
    --with-lockdir=/var/run/samba
    --with-statedir=/var/lib/samba
    --localstatedir=/var/lib/samba
    --with-logfilebase=/var/lib/samba/log
    --with-pammodulesdir=/usr/lib/security/${ISAPART64}
    --with-pam
    --with-syslog
    --with-utmp
    --with-winbind
    --bundled-libraries=ALL
    --private-libraries=ALL
    --without-ad-dc
    --without-regedit
"
# extras
#    --with-system-mitkrb5
#    --localstatedir=/var/samba
#    --sharedstatedir=/var/samba
#    --with-cachedir=/var/cache/samba
#    --with-shared-modules=idmap_rid,idmap_ad,idmap_adex,idmap_hash,idmap_ldap,idmap_tdb2,vfs_dfs_samba4,auth_samba4
#    --with-automount
#    --without-ldap
#    --disable-gnutls
#    --without-ads
#    --without-dnsupdate
#    --disable-avahi
#    --disable-iprint
#    --disable-cups
#    --without-systemd

service_configs() {
    # process template smf manifests (better living through sed(1))
    logmsg "Installing SMF"
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network/samba44
    # can't use logmsg here (screws with stdin/stdout/stderr)
    sed "s@{{PREFIX}}@${PREFIX}@g" \
        $SRCDIR/files/smf/manifest-samba-smbd.xml.tmpl \
        > $DESTDIR/lib/svc/manifest/network/samba44/smbd.xml
    sed "s@{{PREFIX}}@${PREFIX}@g" \
        $SRCDIR/files/smf/manifest-samba-nmbd.xml.tmpl \
        > $DESTDIR/lib/svc/manifest/network/samba44/nmbd.xml
    sed "s@{{PREFIX}}@${PREFIX}@g" \
        $SRCDIR/files/smf/manifest-samba-winbindd.xml.tmpl \
        > $DESTDIR/lib/svc/manifest/network/samba44/winbindd.xml
}

init
download_source pub/samba/stable $PROG $VER
patch_source
prep_build
build
service_configs
generate_localmog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
