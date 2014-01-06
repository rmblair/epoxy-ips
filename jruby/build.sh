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

PROG=jruby    # App name
VER=1.7.9     # App version
VERHUMAN=$VER # Human-readable version
#PVER=         # Branch (set in config.sh, override here if needed)
PKG=$PKGNAMESPACE/language/runtime/jruby # Package name (e.g. library/foo)
SUMMARY="Ruby programming language for the JVM" # One-liner, must be filled in
DESC="JRuby is a high performance, stable, fully threaded Java \
    implementation of the Ruby programming language"

SHORTVER=$(shorten_to_majmin $VER)

# if you provide your own JDK/JRE elsewhere, you can probably lose this
# set of dependencies. We'll assume you know better what this should be ...
DEPENDS_IPS="runtime/java developer/java/jdk"

# reconfigure download to use a global site
MIRROR=jruby.org.s3.amazonaws.com

build_jruby() {
    logmsg "Installing JRuby bits from distribution bin tarball"
    mkdir -p $DESTDIR/$PREFIX/$PROG/$SHORTVER || \
        logerr "--- Failed to create installation directory"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd cp -r bin docs lib samples tool $DESTDIR/$PREFIX/$PROG/$SHORTVER || \
        logerr "--- Failed to copy JRuby bits into DESTDIR"
    popd > /dev/null
}

init
download_source downloads/$VER ${PROG}-bin $VER
prep_build
build_jruby
generate_localmog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
