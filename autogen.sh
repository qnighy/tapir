#!/bin/sh
set -ue

aclocal
autoheader
automake --force-missing --add-missing
autoconf
