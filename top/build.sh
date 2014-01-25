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

PROG=top        # App name
VER=3.7         # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=${PKGNAMESPACE}/system/management/top # Package name (e.g. library/foo)
SUMMARY="Top is a Unix utility that provides a rolling display of top cpu using processes"
DESC="${SUMMARY}"         # Longer description, must be filled in

BUILD_DEPENDS_IPS="library/ncurses"
RUN_DEPENDS_IPS="library/ncurses"

# reconfigure download to use a global site
MIRROR=www.unixtop.org

# it'll build both 32- and 64- anyway
BUILDARCH=64
CONFIGURE_OPTS_64="
  --prefix=$PREFIX/$PROG/$VER
"

init
download_source dist $PROG $VER
patch_source
prep_build
build
#make_isa_stub #top provides its own isa stub thing
generate_localmog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
