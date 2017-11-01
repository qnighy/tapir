#!/bin/sh
set -ue

aclocal
autoheader
automake --force-missing --add-missing --copy
autoconf

if [ -e .git ]; then
  git submodule update --init
fi
cd ruby181; autoconf; cd ..
cd ruby192; autoconf; cd ..
