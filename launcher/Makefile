#!/usr/bin/make -f

CFLAGS += -g -O2 -Wall -Wextra

EXEC = tapir
OBJS = launcher.o ini.o


all: $(EXEC)

clean:
	$(RM) $(EXEC) $(OBJS)

$(EXEC): $(OBJS)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $^ -o $@ $(LDLIBS)

%.o: ../src/%.c
	$(CC) -MMD $(CPPFLAGS) $(CFLAGS) -c $< -o $@

-include $(wildcard *.d)
