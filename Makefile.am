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

test: test-accordion test-violin test-xylophone

test-rgss: test-rgss-accordion test-rgss-violin test-rgss-xylophone

install-exec-local:
	mkdir -p $(DESTDIR)$(PREFIX)/bin $(DESTDIR)$(PREFIX)/share/man/man1
	$(INSTALL) -c bin/tapir-a bin/tapir-v bin/tapir-x bin/tapir \
		$(DESTDIR)$(PREFIX)/bin

install-data-local:
	$(INSTALL) -c -m 644 -t $(DESTDIR)$(PREFIX)/share/man/man1 \
		doc/man/tapir.1

uninstall-local:
	$(RM) $(DESTDIR)$(PREFIX)/bin/tapir-a
	$(RM) $(DESTDIR)$(PREFIX)/bin/tapir-v
	$(RM) $(DESTDIR)$(PREFIX)/bin/tapir-x
	$(RM) $(DESTDIR)$(PREFIX)/bin/tapir
	$(RM) $(DESTDIR)$(PREFIX)/share/man/man1/tapir.1

distclean-local:
	$(RM) -r ruby181-build
	(cd ruby181; git checkout .) || true
	make distclean -C ruby181 || true
	$(RM) -r ruby192-build
	(cd ruby192; git checkout .) || true
	make distclean -C ruby192 || true

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

test-rgss-accordion:
	$(MAKE) test-rgss -C accordion

test-rgss-violin:
	$(MAKE) test-rgss -C violin

test-rgss-xylophone:
	$(MAKE) test-rgss -C xylophone

.PHONY: \
	test test-accordion test-violin test-xylophone \
	test-rgss test-rgss-accordion test-rgss-violin test-rgss-xylophone
