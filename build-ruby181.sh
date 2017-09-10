#!/bin/sh
set -ue

cd "$(dirname "$0")"
dir="$(pwd)"
cd ruby181
if [ ! -e configure ]; then
  autoconf2.59
fi
if [ ! -e Makefile ]; then
  ./configure \
    --prefix="$dir/ruby181-build" \
    --with-static-linked-ext \

fi

echo "option nodynamic" > ext/Setup
echo "zlib" >> ext/Setup

make "$@"
make install
