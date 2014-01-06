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
# Portions Copyright 2013 Greg Mason
#
# Load support functions
. ../../lib/functions.sh
. ../../../lib/more-functions.sh #from epoxy-ips-bootstrap
. vars.sh

PROG="puppet" # App name
VER=${PUPPET_VER} # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=$PKGNAMESPACE/system/management/puppet
SUMMARY="A network tool for managing many disparate systems"
DESC="Puppet lets you centrally manage every important aspect of your system using a cross-platform specification language that manages all the separate elements normally aggregated in different files, like users, cron jobs, and hosts along with obviously discrete elements like packages, services, and files."
SHORTVER=$(shorten_to_majmin $VER)

RUBY_SHORTVER=$(shorten_to_majmin $RUBY_VER)
FACTER_SHORTVER=$(shorten_to_majmin $FACTER_VER)
HIERA_SHORTVER=$(shorten_to_majmin $HIERA_VER)
RUBY_AUGEAS_SHORTVER=$(shorten_to_majmin $RUBY_AUGEAS_VER)

BUILD_DEPENDS_IPS="
    $PKGNAMESPACE/system/management/puppet-private-ruby@${RUBY_SHORTVER}
    $PKGNAMESPACE/system/management/facter@${FACTER_SHORTVER}
    $PKGNAMESPACE/system/management/hiera@${HIERA_SHORTVER}
    $PKGNAMESPACE/system/management/puppet-private-ruby-augeas@${RUBY_AUGEAS_SHORTVER}
"

DEPENDS_IPS="${BUILD_DEPENDS_IPS}"

# reconfigure download to use a global site
MIRROR=downloads.puppetlabs.com

RUBY_BIN=$PREFIX/puppet/ruby/$RUBY_SHORTVER/bin/ruby
PUPPET_PREFIX_BIN=$PREFIX/puppet/bin

just_install_it() {
    logmsg "Just installing it!"
    logcmd pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd $RUBY_BIN install.rb \
        --destdir=${DESTDIR} \
        --configdir=${PREFIX}/puppet/etc/puppet \
        --full > /dev/null
    logcmd popd > /dev/null
}

clean_localmog() {
    rm -f local.mog.tmpl local.mog
}

twiddle_license() {
    echo "license LICENSE license=Apachev2" >> local.mog.tmpl
}

inject_links_localmog() {
    echo "link path={{PREFIX}}/puppet/bin/puppet" \
        "target=/{{PREFIX}}/puppet/ruby/$RUBY_SHORTVER/bin/puppet" \
        >> local.mog.tmpl
}

init
download_source $PROG $PROG $VER
prep_build
just_install_it
clean_localmog
twiddle_license
inject_links_localmog
generate_localmog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
