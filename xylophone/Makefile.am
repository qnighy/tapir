#!/usr/bin/make -f

# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

RGSS = 1
RUBY_SRC_DIR = ../ruby181
RUBY_DIR = ../ruby181-build
EXEC = tapir-x
tapir_x_SOURCES = $(tapir_SOURCES)
CPPFLAGS += -I$(RUBY_DIR)/lib/ruby/1.8/$(RUBY_PLATFORM) \
	    -DRGSS=$(RGSS)

BUILT_SOURCES = ../ruby181-build

../ruby181-build:
	make ruby181-build -C ..

include ../src/common.mk
