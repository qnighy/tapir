#!/usr/bin/make -f

# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

RGSS = 2
RUBY_SRC_DIR = ../ruby181
RUBY_DIR = ../ruby181-build
EXEC = ../bin/tapir-v
CPPFLAGS += -I$(RUBY_DIR)/lib/ruby/1.8/$(RUBY_PLATFORM) \
	    -DRGSS=$(RGSS)
LDLIBS = $(RUBY_SRC_DIR)/ext/nkf/nkf.a
include ../src/common.mk
