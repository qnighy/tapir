#!/bin/sh
set -ue

echo "Generating aclocal.m4..." >&2
aclocal-1.15
echo "Generating src/config.h.in..." >&2
autoheader
echo "Generating Makefile.in..." >&2
automake-1.15 --force-missing --add-missing --copy
echo "Generating configure..." >&2
autoconf

if [ -e .git ]; then
  echo "Updating ruby181..." >&2
  git submodule update --init ruby181
  echo "Updating ruby192..." >&2
  git submodule update --init ruby192
fi
echo "Generating ruby181/configure..." >&2
cd ruby181; autoconf; cd ..
echo "Generating ruby192/configure..." >&2
cd ruby192; autoconf; cd ..

echo "autogen.sh: success" >&2
