#!/bin/sh

# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

set -ue

cd "$(dirname "$0")"
dir="$(pwd)"

if [ -e .git ]; then
  git submodule update --init ruby181
fi

cd ruby181
if [ ! -e configure ]; then
  autoconf
fi
if [ ! -e Makefile ]; then
  ./configure \
    --prefix="$dir/ruby181-build" \

fi

echo "option nodynamic" > ext/Setup.tapir
echo "zlib" >> ext/Setup.tapir
echo "nkf" >> ext/Setup.tapir

sed -i.bak -e 's/"Setup"/"Setup.tapir"/' config.status
rm -f config.status.bak
if [ -e rbconfig.rb ]; then
  sed -i.bak -e 's/"Setup"/"Setup.tapir"/' rbconfig.rb
  rm -f rbconfig.rb.bak
fi

make "$@"
make install
