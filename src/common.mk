# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

RUBY_PLATFORM := $(shell $(RUBY_DIR)/bin/ruby -e 'print RUBY_PLATFORM')

OBJS = main.o main_rb.o archive.o openres.o gl_misc.o sdl_misc.o misc.o \
       font_lookup.o ini.o config.o \
       Bitmap.o BitmapArray.o \
       Audio.o Color.o Font.o Graphics.o Input.o Plane.o \
       RGSSError.o RGSSReset.o Rect.o Sprite.o Table.o Tilemap.o Tone.o \
       Viewport.o Win32APIFake.o Window.o
CFLAGS += -g -O2 -Wall -Wextra \
	  $(SDL_CFLAGS) $(GL_CFLAGS) $(FONTCONFIG_CFLAGS) $(LIBCONFIG_CFLAGS)
LDFLAGS += -L$(RUBY_DIR)/lib
LDLIBS += $(RUBY_SRC_DIR)/ext/zlib/zlib.a -lz \
	  -lruby-static -lpthread -lrt -ldl -lcrypt -lm \
	  $(SDL_LIBS) $(GL_LIBS) $(FONTCONFIG_LIBS) $(LIBCONFIG_LIBS)

all: $(EXEC)

clean:
	$(RM) $(EXEC) $(OBJS) $(wildcard *.d)

test: all
	mkdir -p test
	cd test; ruby ../../src/test/test.rb $(RGSS) ../$(EXEC)

test-rgss:
	mkdir -p test
	cd test; ruby ../../src/test/test.rb $(RGSS) ./Game

.PHONY: all clean test test-rgss

$(EXEC): $(OBJS)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $^ -o $@ $(LDLIBS)

%.o: ../src/%.c
	$(CC) -MMD $(CPPFLAGS) $(CFLAGS) -c $< -o $@

-include $(wildcard *.d)
