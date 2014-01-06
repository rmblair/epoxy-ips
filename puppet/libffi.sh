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

PROG=libffi     # App name
VER=${FFI_VER} # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=$PKGNAMESPACE/system/management/puppet-private-libffi
SUMMARY="[Puppet private] A Portable Foreign Function Interface Library"
DESC="${SUMMARY}"         # Longer description, must be filled in
SHORTVER=$(shorten_to_majmin $VER)

# reconfigure download to use a global site
MIRROR=www.mirrorservice.org

BUILDARCH=64
CONFIGURE_OPTS_64="
    --prefix=$PREFIX/puppet/$PROG/$SHORTVER
    --includedir=$PREFIX/puppet/$PROG/$SHORTVER/include
"


twiddle_license() {
    rm -f local.mog.tmpl local.mog
    echo "license LICENSE license=MIT" > local.mog.tmpl

    # extreme makefile stupid that --includedir does not fix
    echo "<transform file path={{PREFIX}}/puppet/libffi/$SHORTVER/lib/libffi-(.*)/include/(.*)$ -> edit path {{PREFIX}}/puppet/libffi/$SHORTVER/lib/libffi-(.*)/include/(.*)$ {{PREFIX}}/puppet/libffi/$SHORTVER/include/%<2> >" >> local.mog.tmpl
}

init
download_source sites/sourceware.org/pub/libffi $PROG $VER
patch_source
prep_build
build
twiddle_license
generate_localmog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
