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

PROG=ruby       # App name
VER=${RUBY_VER} # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=$PKGNAMESPACE/system/management/puppet-private-ruby
SUMMARY="[Puppet private] Ruby programming language"
DESC="${SUMMARY}"         # Longer description, must be filled in
SHORTVER=$(shorten_to_majmin $VER)

AUGEAS_SHORTVER=$(shorten_to_majmin $AUGEAS_VER)
FFI_SHORTVER=$(shorten_to_majmin $FFI_VER)
YAML_SHORTVER=$(shorten_to_majmin $YAML_VER)

DEPENDS_IPS="
    $PKGNAMESPACE/system/management/puppet-private-augeas@${AUGEAS_SHORTVER}
    $PKGNAMESPACE/system/management/puppet-private-libffi@${FFI_SHORTVER}
    $PKGNAMESPACE/system/management/puppet-private-yaml@${YAML_SHORTVER}
"

BUILD_DEPENDS_IPS="
    ${DEPENDS_IPS}
    $PKGNAMESPACE/language/runtime/jruby@9.0
"

# reconfigure download to use a global site
MIRROR=cache.ruby-lang.org

BUILDARCH=64
CONFIGURE_OPTS_64="
    --prefix=$PREFIX/puppet/$PROG/$SHORTVER
    --enable-rpath
    --with-baseruby=$PREFIX/jruby/1.7/bin/jruby
    --disable-install-doc
    --disable-install-rdoc
    --disable-install-capi
    --with-opt-dir=$PREFIX/puppet/augeas/$AUGEAS_SHORTVER:$PREFIX/puppet/yaml/$YAML_SHORTVER:$PREFIX/puppet/libffi/$FFI_SHORTVER
    --enable-dtrace
"

MAKE=gmake

# for jruby encoding silliness
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_ALL=en_US.UTF-8

# summon signbit macro into existence
CFLAGS="-D_GNU_SOURCE --std=c99"

twiddle_license() {
    rm -f local.mog.tmpl local.mog
    echo "license COPYING license=BSDL_Ruby" > local.mog.tmpl
    echo "license COPYING.ja license=BSDL_Ruby_JA" >> local.mog.tmpl
    echo "license LEGAL license=Ruby_Other" >> local.mog.tmpl
}

# ruby is not a repeatable build, at least with jruby as 'baseruby'
# so whack the entire unpacked tree *first*
cleanup_first() {
    logmsg "Cleaning up old build directory"

    # somehow $TMPDIR/$BUILDDIR are unpopulated?
    if [[ "/" == "$TMPDIR/$BUILDDIR" ]]; then
        logerr "something is horribly wrong ... \$TMPDIR/\$BUILDDIR == /"
        exit 1
    fi

    # unpacked tree goes away!
    if [[ -d "$TMPDIR/$BUILDDIR" ]]; then
        logcmd rm -fr $TMPDIR/$BUILDDIR > /dev/null
    fi
}

init
cleanup_first
download_source pub/ruby/$SHORTVER $PROG $VER
VER=${VER/-p/.} # cribbed from omnios-build/build/ruby-19 in omniti-ms branch
patch_source
prep_build
build
twiddle_license
generate_localmog
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
