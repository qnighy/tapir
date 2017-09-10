#!/bin/sh
set -ue

cd "$(dirname "$0")"
dir="$(pwd)"
cd ruby192
if [ ! -e configure ]; then
  autoconf
fi
if [ ! -e Makefile ]; then
  ./configure \
    --prefix="$dir/ruby192-build" \
    --disable-install-doc \
    --with-ext= \
    --with-static-linked-ext \

fi

echo "option nodynamic" > ext/Setup
echo "zlib" >> ext/Setup

make "$@"
make install
