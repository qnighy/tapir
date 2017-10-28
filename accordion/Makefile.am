#!/usr/bin/make -f

# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

RGSS = 3
RUBY_SRC_DIR = ../ruby192
RUBY_DIR = ../ruby192-build
EXEC = tapir-a
tapir_a_SOURCES = $(tapir_SOURCES)
CPPFLAGS += -I$(RUBY_DIR)/include/ruby-1.9.1/$(RUBY_PLATFORM) \
	    -I$(RUBY_DIR)/include/ruby-1.9.1 \
	    -DRGSS=$(RGSS)
LIBS = $(RUBY_SRC_DIR)/enc/trans/single_byte.o \
       $(RUBY_SRC_DIR)/enc/trans/utf_16_32.o \
       $(RUBY_SRC_DIR)/enc/trans/japanese_sjis.o

BUILT_SOURCES = ../ruby192-build

../ruby192-build:
	make ruby192-build -C ..

include ../src/common.mk
