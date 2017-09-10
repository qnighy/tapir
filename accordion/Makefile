#!/usr/bin/make -f

RUBY_SRC_DIR = ../ruby192
RUBY_DIR = ../ruby192-build
RUBY_PLATFORM = $(shell $(RUBY_DIR)/bin/ruby -e 'print RUBY_PLATFORM')

EXEC = tapir-a
OBJS = main.o
CFLAGS += -O2 -Wall -Wextra
CPPFLAGS += -I$(RUBY_DIR)/include/ruby-1.9.1/$(RUBY_PLATFORM) \
	    -I$(RUBY_DIR)/include/ruby-1.9.1 \
	    -DRGSS=3
LDFLAGS += -L$(RUBY_DIR)/lib
LDLIBS = -lruby-static -lpthread -lrt -ldl -lcrypt -lm

all: $(EXEC)

clean:
	$(RM) $(EXEC) $(OBJS)

.PHONY: all

$(EXEC): $(OBJS)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $^ -o $@ $(LDLIBS)

%.o: ../src/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
