#!/usr/bin/make -f

# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

PREFIX ?= /usr/local
INSTALL ?= install

all: all-accordion all-violin all-xylophone all-launcher

clean: clean-accordion clean-violin clean-xylophone clean-launcher

test: test-accordion test-violin test-xylophone

test-rgss: test-rgss-accordion test-rgss-violin test-rgss-xylophone

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin $(DESTDIR)$(PREFIX)/share/man/man1
	$(INSTALL) -c bin/tapir-a bin/tapir-v bin/tapir-x bin/tapir \
		$(DESTDIR)$(PREFIX)/bin
	$(INSTALL) -c -m 644 -t $(DESTDIR)$(PREFIX)/share/man/man1 \
		doc/man/tapir.1

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/tapir-a
	$(RM) $(DESTDIR)$(PREFIX)/bin/tapir-v
	$(RM) $(DESTDIR)$(PREFIX)/bin/tapir-x
	$(RM) $(DESTDIR)$(PREFIX)/bin/tapir
	$(RM) $(DESTDIR)$(PREFIX)/share/man/man1/tapir.1

all-accordion:
	$(MAKE) all -C accordion
	cp accordion/tapir-a bin/tapir-a

all-violin:
	$(MAKE) all -C violin
	cp violin/tapir-v bin/tapir-v

all-xylophone:
	$(MAKE) all -C xylophone
	cp xylophone/tapir-x bin/tapir-x

all-launcher:
	$(MAKE) all -C launcher
	cp launcher/tapir bin/tapir

clean-accordion:
	$(RM) bin/tapir-a
	$(MAKE) clean -C accordion

clean-violin:
	$(RM) bin/tapir-v
	$(MAKE) clean -C violin

clean-xylophone:
	$(RM) bin/tapir-x
	$(MAKE) clean -C xylophone

clean-launcher:
	$(RM) bin/tapir
	$(MAKE) clean -C launcher

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
	all all-accordion all-violin all-xylophone \
	clean clean-accordion clean-violin clean-xylophone \
	test test-accordion test-violin test-xylophone \
	test-rgss test-rgss-accordion test-rgss-violin test-rgss-xylophone \
	launcher clean-launcher
