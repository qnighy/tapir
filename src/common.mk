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
OBJS = main.o
CFLAGS += -O2 -Wall -Wextra
ifeq ($(RGSS),3)
CPPFLAGS += -I$(RUBY_DIR)/include/ruby-1.9.1/$(RUBY_PLATFORM) \
	    -I$(RUBY_DIR)/include/ruby-1.9.1 \
	    -DRGSS=$(RGSS)
else
CPPFLAGS += -I$(RUBY_DIR)/lib/ruby/1.8/$(RUBY_PLATFORM) \
	    -DRGSS=$(RGSS)
endif
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
