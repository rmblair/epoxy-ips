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

PROG="facter" # App name
VER=${FACTER_VER} # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=$PKGNAMESPACE/system/management/puppet-private-facter
SUMMARY="[Puppet private] Host Fact Detection and Reporting"
DESC="Facter is an independent, cross-platform Ruby library designed to gather information on all the nodes you will be managing with Puppet. It is available on all platforms that Puppet is available."
SHORTVER=$(shorten_to_majmin $VER)

AUGEAS_SHORTVER=$(shorten_to_majmin $AUGEAS_VER)
RUBY_SHORTVER=$(shorten_to_majmin $RUBY_VER)

BUILD_DEPENDS_IPS="
    $PKGNAMESPACE/system/management/puppet-private-ruby@${RUBY_SHORTVER}
"

DEPENDS_IPS="${BUILD_DEPENDS_IPS}"

# reconfigure download to use a global site
MIRROR=downloads.puppetlabs.com

RUBY_BIN=$PREFIX/puppet/ruby/$RUBY_SHORTVER/bin/ruby
PUPPET_PREFIX_BIN=$PREFIX/puppet/bin

just_install_it() {
    logmsg "Just installing it!"
    logcmd pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd $RUBY_BIN install.rb --destdir=${DESTDIR} --full
    logcmd popd > /dev/null
}

clean_localmog() {
    rm -f local.mog.tmpl local.mog
}

twiddle_license() {
    echo "license LICENSE license=Apachev2" >> local.mog.tmpl
}

inject_links_localmog() {
    echo "link path={{PREFIX}}/puppet/bin/facter" \
        "target=/{{PREFIX}}/puppet/ruby/$RUBY_SHORTVER/bin/facter" \
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
