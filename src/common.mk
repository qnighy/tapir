PC_LIBS = sdl2 SDL2_image SDL2_ttf fontconfig gl

ifeq ($(RGSS),3)
RUBY_SRC_DIR = ../ruby192
RUBY_DIR = ../ruby192-build
else
RUBY_SRC_DIR = ../ruby181
RUBY_DIR = ../ruby181-build
endif
RUBY_PLATFORM = $(shell $(RUBY_DIR)/bin/ruby -e 'print RUBY_PLATFORM')

ifeq ($(RGSS),3)
EXEC = tapir-a
else
ifeq ($(RGSS),2)
EXEC = tapir-v
else
EXEC = tapir-x
endif
endif
OBJS = main.o main_rb.o archive.o openres.o gl_misc.o sdl_misc.o misc.o \
       font_lookup.o \
       Bitmap.o BitmapArray.o \
       Color.o Font.o Graphics.o Input.o RGSSError.o RGSSReset.o \
       Rect.o Sprite.o Table.o Tilemap.o Tone.o \
       Viewport.o Win32APIFake.o Window.o
CFLAGS += -g -O2 -Wall -Wextra
ifeq ($(RGSS),3)
CPPFLAGS += -I$(RUBY_DIR)/include/ruby-1.9.1/$(RUBY_PLATFORM) \
	    -I$(RUBY_DIR)/include/ruby-1.9.1 \
	    $(shell pkg-config $(PC_LIBS) --cflags-only-I) \
	    -DRGSS=$(RGSS)
else
CPPFLAGS += -I$(RUBY_DIR)/lib/ruby/1.8/$(RUBY_PLATFORM) \
	    $(shell pkg-config $(PC_LIBS) --cflags-only-I) \
	    -DRGSS=$(RGSS)
endif
LDFLAGS += -L$(RUBY_DIR)/lib \
	   $(shell pkg-config $(PC_LIBS) --libs-only-L --libs-only-other)
LDLIBS = $(RUBY_SRC_DIR)/ext/zlib/zlib.a -lz \
	 -lruby-static -lpthread -lrt -ldl -lcrypt -lm \
	 $(shell pkg-config $(PC_LIBS) --libs-only-l)

all: $(EXEC)

clean:
	$(RM) $(EXEC) $(OBJS)

test:
	mkdir -p test
	cd test; ruby ../../src/test/test.rb $(RGSS) ../$(EXEC)

.PHONY: all clean test

$(EXEC): $(OBJS)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $^ -o $@ $(LDLIBS)

%.o: ../src/%.c
	$(CC) -MMD $(CPPFLAGS) $(CFLAGS) -c $< -o $@

-include $(wildcard *.d)
