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
. vars.sh

PROG="ruby-augeas" # App name
VER=${RUBY_AUGEAS_VER} # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=$PKGNAMESPACE/system/management/puppet-private-ruby-augeas
SUMMARY="[Puppet private] Augeas is a configuration editing tool (Ruby binding)"
DESC="${SUMMARY}"         # Longer description, must be filled in
SHORTVER=$(shorten_to_majmin $VER)

AUGEAS_SHORTVER=$(shorten_to_majmin $AUGEAS_VER)
RUBY_SHORTVER=$(shorten_to_majmin $RUBY_VER)

BUILD_DEPENDS_IPS="
    library/libxml2
    $PKGNAMESPACE/system/management/puppet-private-ruby@${RUBY_SHORTVER}
    $PKGNAMESPACE/system/management/puppet-private-augeas@${AUGEAS_SHORTVER}
"

DEPENDS_IPS="${BUILD_DEPENDS_IPS}"

# reconfigure download to use a global site
MIRROR=download.augeas.net

# gem/rake generated GNUmake, not make compatible files
MAKE=gmake

#modified from ../lib/gem-functions.sh
GEM_BIN=$PREFIX/puppet/ruby/$RUBY_SHORTVER/bin/gem
RAKE_BIN=$PREFIX/puppet/ruby/$RUBY_SHORTVER/bin/rake

# this is what ruby uses in its gem path, despite being != current (1.9.3?)
RUBY_VER=1.9.1

# match where ruby lives
RUBY_PREFIX=$PREFIX/puppet/ruby/$RUBY_SHORTVER

custom_build64() {
    logmsg "Building"

    if [[ -e $SRCDIR/files/gemrc ]]; then
        GEMRC=$SRCDIR/files/gemrc
    else
        GEMRC=$MYDIR/gemrc
    fi

    pushd $TMPDIR/$BUILDDIR > /dev/null
    GEM_HOME=${DESTDIR}${RUBY_PREFIX}/lib/ruby/gems/${RUBY_VER}
    export GEM_HOME

    # build as a gem first ...
    logmsg "--- rake gem $PROG-$VER"
    logcmd $RAKE_BIN -v -t gem|| \
        logerr "Failed to rake gem $PROG-$VER"

    # then gem install it from local
    logmsg "--- gem install $PROG-$VER"
    logcmd $GEM_BIN --config-file $GEMRC install \
         --no-rdoc --no-ri --install-dir ${GEM_HOME} \
         --local pkg/$PROG-$VER.gem || \
        logerr "Failed to gem install $PROG-$VER"
}

twiddle_license() {
    rm -f local.mog.tmpl local.mog
    echo "license COPYING license=LGPLv2" > local.mog.tmpl
}

# use a patchdir specific to this build
PATCHDIR=patches/$PROG

init
download_source ruby $PROG $VER
patch_source
prep_build

# something about the gem-functions.sh makes this necessary to occur earlier
twiddle_license
generate_localmog

custom_build64
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
