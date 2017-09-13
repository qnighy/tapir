#include <stdio.h>
#include <ruby.h>
#include <SDL.h>
#include "main_rb.h"
#include "misc.h"
#include "sdl_misc.h"
#include "Color.h"
#include "Graphics.h"
#include "Rect.h"
#include "Table.h"
#include "Tone.h"

void Init_zlib(void);
static void Init_RGSS(void);

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
    Init_RGSS();
    rb_protect(main_rb, Qnil, &state);
  }
#else
  {
    (void) ruby_argc;
    (void) ruby_argv;
    ruby_init();
    Init_zlib();
    Init_RGSS();
    {
      extern void Init_stack(void *addr);
      Init_stack(__builtin_frame_address(0));
      rb_protect(main_rb, Qnil, &state);
    }
  }
#endif

  cleanupSDL();
  return state;
}

static void Init_RGSS(void) {
  Init_Rect();
  Init_Color();
  Init_Tone();
  Init_Table();
  Init_Graphics();
}
