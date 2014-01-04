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

PROG=emacs      # App name
VER=24.3        # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=editor/emacs # Package name (e.g. library/foo)
SUMMARY="GNU Emacs is an extensible, customizable text editor--and more"
DESC="${SUMMARY}"         # Longer description, must be filled in

BUILD_DEPENDS_IPS="library/ncurses"
RUN_DEPENDS_IPS="library/ncurses"

# reconfigure download to use a global site
MIRROR=ftp.gnu.org

# for some reason, it choses termcap instead
LDFLAGS="-lcurses"

BUILDARCH=64
# we don't have X11, but don't try finding it either
CONFIGURE_OPTS_64="
    --prefix=/opt/$PKGPUBLISHER/$PROG/$VER
    --without-all
"

init
download_source gnu/emacs $PROG $VER
patch_source
prep_build
build
make_isa_stub
generate_localmog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
