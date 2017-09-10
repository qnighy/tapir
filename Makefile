#!/usr/bin/make -f

all: all-accordion all-violin all-xylophone

clean: clean-accordion clean-violin clean-xylophone

.PHONY: all clean all-accordion all-violin all-xylophone clean-accordion clean-violin clean-xylophone

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
