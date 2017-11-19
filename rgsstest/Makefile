#!/usr/bin/make -f

test: test-rgss3 test-rgss2 test-rgss1

clean: clean-rgss3 clean-rgss2 clean-rgss1

test-rgss3:
	cd rgss3; ruby ../../src/test/test.rb rgss 3 ./Game.exe

test-rgss2:
	cd rgss2; ruby ../../src/test/test.rb rgss 2 ./Game.exe

test-rgss1:
	cd rgss1; ruby ../../src/test/test.rb rgss 1 ./Game.exe

clean-rgss3:
	cd rgss3; $(RM) Game.ini Data/Scripts.rvdata2 stderr.txt stdout.txt
	$(RM) $(wildcard rgss3/*actual.png rgss3/*expected.png)

clean-rgss2:
	cd rgss2; $(RM) Game.ini Data/Scripts.rvdata stderr.txt stdout.txt
	$(RM) $(wildcard rgss2/*actual.png rgss2/*expected.png)

clean-rgss1:
	cd rgss1; $(RM) Game.ini Data/Scripts.rxdata stderr.txt stdout.txt
	$(RM) $(wildcard rgss1/*actual.png rgss1/*expected.png)

.PHONY: \
	test test-rgss3 test-rgss2 test-rgss1 \
	clean clean-rgss3 clean-rgss2 clean-rgss1
