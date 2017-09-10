#!/usr/bin/make -f

RUBY_SRC_DIR = ../ruby181
RUBY_DIR = ../ruby181-build
RUBY_PLATFORM = $(shell $(RUBY_DIR)/bin/ruby -e 'print RUBY_PLATFORM')

EXEC = tapir-v
OBJS = main.o
CFLAGS += -O2 -Wall -Wextra
CPPFLAGS += -I$(RUBY_DIR)/lib/ruby/1.8/$(RUBY_PLATFORM) \
	    -DRGSS=2
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
