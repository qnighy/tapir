#include <stdio.h>
#include <ruby.h>
#include <SDL.h>
#include "main_rb.h"
#include "misc.h"
#include "sdl_misc.h"

void Init_zlib(void);

#ifdef RUBY_GLOBAL_SETUP
RUBY_GLOBAL_SETUP
#endif

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
    rb_protect(main_rb, Qnil, &state);
  }
#else
  {
    (void) ruby_argc;
    (void) ruby_argv;
    ruby_init();
    Init_zlib();
    {
      extern void Init_stack(void *addr);
      Init_stack(__builtin_frame_address(0));
      rb_protect(main_rb, Qnil, &state);
    }
  }
#endif

  loopSDL();
  cleanupSDL();
  return state;
}
