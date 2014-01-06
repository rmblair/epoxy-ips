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

PROG="hiera" # App name
VER=${HIERA_VER} # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=$PKGNAMESPACE/system/management/puppet-private-hiera
SUMMARY="[Puppet private] A simple pluggable Hierarchical Database."
DESC="${SUMMARY}"
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

gem_install() {
    logmsg "Using RubyGems to install $PROG"
    logcmd pushd $TMPDIR/$BUILDDIR > /dev/null
    if [[ ! -f lib/hiera/util.rb.orig ]]; then
        logmsg "--- making backup of lib/hiera/util.rb"
        logcmd mv lib/hiera/util.rb lib/hiera/util.rb.orig
    fi

    # hiera/util.rb ships looking for config in /etc, here we fix this
    logmsg "--- editing lib/hiera/util.rb"
    sed s@/etc@$PREFIX/puppet/etc@g < lib/hiera/util.rb.orig > lib/hiera/util.rb

    logcmd $RUBY_BIN install.rb \
        --destdir=${DESTDIR} \
        --configdir=${PREFIX}/puppet/etc \
        --full
    logcmd popd > /dev/null
}

clean_localmog() {
    rm -f local.mog.tmpl local.mog
}

twiddle_license() {
    echo "license LICENSE license=Apachev2" >> local.mog.tmpl
}

inject_links_localmog() {
    echo "link path={{PREFIX}}/puppet/bin/hiera" \
        "target=/{{PREFIX}}/puppet/ruby/$RUBY_SHORTVER/bin/hiera" \
        >> local.mog.tmpl

    ### deal with hiera.yaml
    # without hacking hiera/util.rb, this link needs to be added
    # (Hiera::Util.config_dir = /etc)
    #echo "link path=/etc/hiera.yaml" \
    #    "target=/{{PREFIX}}/puppet/etc/hiera.yaml" \
    #    >> local.mog.tmpl
    ### for now, just drop it
    #echo "<transform file path={{PREFIX}}/puppet/etc/hiera.yaml$ -> drop>" >> local.mog.tmpl
    ### for now, just rename it
    #echo "<transform file path={{PREFIX}}/puppet/etc/hiera.yaml$ -> edit path {{PREFIX}}/puppet/etc/hiera.yaml$ {{PREFIX}}/puppet/etc/hiera.yaml.dist>" >> local.mog.tmpl
}

init
download_source $PROG $PROG $VER
prep_build
gem_install
clean_localmog
twiddle_license
inject_links_localmog
generate_localmog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
