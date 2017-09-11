#include <stdio.h>
#include <ruby.h>
#include <SDL.h>
#include "misc.h"
#include "sdl_misc.h"

void Init_zlib(void);

#ifdef RUBY_GLOBAL_SETUP
RUBY_GLOBAL_SETUP
#endif

static VALUE protected_main(VALUE data);

int main(int argc, char **argv) {
  int ruby_argc = 2;
  char *ruby_argv_array[] = {
    (char*)"ruby",
    NULL
  };
  char **ruby_argv = ruby_argv_array;
  int state = 0;

  if(argc >= 2) {
    tryChdir(argv[1]);
  }

  initSDL();

#ifdef RUBY_INIT_STACK
  ruby_sysinit(&ruby_argc, &ruby_argv);
  {
    RUBY_INIT_STACK;
    ruby_init();
    Init_zlib();
    rb_protect(protected_main, Qnil, &state);
  }
#else
  {
    (void) ruby_argc;
    (void) ruby_argv;
    ruby_init();
    Init_zlib();
    rb_protect(protected_main, Qnil, &state);
  }
#endif

  loopSDL();
  cleanupSDL();
  return state;
}

static VALUE protected_main(VALUE data) {
  (void) data;

  rb_eval_string("print \"Hello, world!\\n\"");
  rb_eval_string("p RUBY_VERSION");
  return Qnil;
}
