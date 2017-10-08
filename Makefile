#!/usr/bin/make -f

all: all-accordion all-violin all-xylophone

clean: clean-accordion clean-violin clean-xylophone

test: test-accordion test-violin test-xylophone

test-rgss: test-rgss-accordion test-rgss-violin test-rgss-xylophone

.PHONY: \
	all all-accordion all-violin all-xylophone \
	accordion violin xylophone \
	clean clean-accordion clean-violin clean-xylophone \
	test test-accordion test-violin test-xylophone \
	test-rgss test-rgss-accordion test-rgss-violin test-rgss-xylophone

all-accordion:
	$(MAKE) all -C accordion

all-violin:
	$(MAKE) all -C violin

all-xylophone:
	$(MAKE) all -C xylophone

clean-accordion:
	$(MAKE) clean -C accordion

clean-violin:
	$(MAKE) clean -C violin

clean-xylophone:
	$(MAKE) clean -C xylophone

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

accordion: all-accordion

violin: all-violin

xylophone: all-xylophone
