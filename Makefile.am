#!/usr/bin/make -f

# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

SUBDIRS = accordion violin xylophone launcher
man1_MANS = doc/man/tapir-x.1 doc/man/tapir-v.1 doc/man/tapir-a.1 \
	    doc/man/tapir.1

test: test-accordion test-violin test-xylophone

test-rgss: test-rgss-accordion test-rgss-violin test-rgss-xylophone

distclean-local:
	$(RM) -r ruby181-build
	$(RM) ruby181/ext/Setup.tapir
	make distclean -C ruby181 || true
	$(RM) -r ruby192-build
	$(RM) ruby192/ext/Setup.tapir
	make realclean -C ruby192 || true
	$(RM) -r autom4te.cache
	$(RM) -r ruby181/autom4te.cache ruby181/parse.c
	$(RM) -r ruby192/autom4te.cache ruby192/.ext ruby192/ext/zlib/zlib.a

ruby181-build:
	./build-ruby181.sh

ruby192-build:
	./build-ruby192.sh

test-accordion:
	$(MAKE) test -C accordion

test-violin:
	$(MAKE) test -C violin

test-xylophone:
	$(MAKE) test -C xylophone

.PHONY: \
	test test-accordion test-violin test-xylophone
