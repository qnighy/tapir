#!/usr/bin/make -f

all: all-accordion all-violin all-xylophone

clean: clean-accordion clean-violin clean-xylophone

test: test-accordion test-violin test-xylophone

.PHONY: \
	all all-accordion all-violin all-xylophone \
	accordion violin xylophone \
	clean clean-accordion clean-violin clean-xylophone \
	test test-accordion test-violin test-xylophone

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

accordion: all-accordion

violin: all-violin

xylophone: all-xylophone
