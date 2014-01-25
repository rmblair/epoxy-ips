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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
# Portions Copyright 2014 Ryan Blair
#
# Load support functions
. ../../lib/functions.sh
. ../../../lib/more-functions.sh #from epoxy-ips-bootstrap

PROG=cvs        # App name
VER=1.11.23     # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=$PKGNAMESPACE/developer/versioning/cvs # Package name (e.g. library/foo)
SUMMARY="Concurrent Versions System" # One-liner, must be filled in
DESC="$SUMMARY"         # Longer description, must be filled in
SHORTVER=$(shorten_to_majmin $VER)

# reconfigure download to use a global site
MIRROR=ftp.gnu.org

# issues building 64-bit CVS, and it's not really necessary
BUILDARCH=32
CONFIGURE_OPTS_32="
  --prefix=$PREFIX/$PROG/$SHORTVER
  --with-ssh=/usr/bin/ssh
  --with-editor=/usr/bin/vim
  --enable-client
  --enable-server
"

init
download_source non-gnu/cvs/source/stable/$VER/ $PROG $VER
prep_build
build
#make_isa_stub #only building 32b anyway
generate_localmog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
