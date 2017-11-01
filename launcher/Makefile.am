#!/usr/bin/make -f

# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

EXEC = tapir
bin_PROGRAMS = $(EXEC)
tapir_SOURCES = launcher.c ini.c


all-local: $(EXEC)
	cp $(EXEC) ../bin/$(EXEC)

clean-local:
	$(RM) ../bin/$(EXEC)

VPATH += ../src
