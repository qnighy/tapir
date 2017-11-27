# Copyright 2017 Masaki Hara. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

RUBY_PLATFORM := $(shell $(RUBY_DIR)/bin/ruby -e 'print RUBY_PLATFORM')

bin_PROGRAMS = $(EXEC)
tapir_SOURCES = main.c main_rb.c archive.c openres.c gl_misc.c sdl_misc.c \
		surface_misc.c misc.c font_lookup.c ini.c tapir_config.c \
		Bitmap.c BitmapArray.c \
		Audio.c Color.c Font.c Graphics.c Input.c Plane.c \
		RGSSError.c RGSSReset.c Rect.c Sprite.c Table.c Tilemap.c \
		Tone.c Viewport.c Win32APIFake.c Window.c

CFLAGS += $(SDL_CFLAGS) $(GL_CFLAGS) $(FONTCONFIG_CFLAGS) $(LIBCONFIG_CFLAGS)
LDFLAGS += -L$(RUBY_DIR)/lib
LIBS += $(RUBY_SRC_DIR)/ext/zlib/zlib.a -lz \
	-lruby-static -lpthread -lrt -ldl -lcrypt -lm \
	$(SDL_LIBS) $(GL_LIBS) $(FONTCONFIG_LIBS) $(LIBCONFIG_LIBS)

all-local: $(EXEC)
	cp $(EXEC) ../bin/$(EXEC)

clean-local:
	$(RM) ../bin/$(EXEC)
	cd test; $(RM) *actual.png *expected.png stderr.txt stdout.txt \
		Game.ini Data/Scripts.*

test: all
	mkdir -p test
	cd test; ruby ../../src/test/test.rb tapir $(RGSS) ../../bin/$(EXEC)

.PHONY: test

VPATH += ../src
