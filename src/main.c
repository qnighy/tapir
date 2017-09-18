#include <stdio.h>
#include <stdbool.h>
#include <ruby.h>
#include <SDL.h>
#include "main_rb.h"
#include "misc.h"
#include "sdl_misc.h"
#include "archive.h"
#include "openres.h"
#include "Bitmap.h"
#include "Color.h"
#include "Graphics.h"
#include "Input.h"
#include "RGSSError.h"
#include "RGSSReset.h"
#include "Rect.h"
#include "Sprite.h"
#include "Table.h"
#include "Tone.h"
#include "Viewport.h"
#include "Window.h"

static bool is_test_mode = false;
static bool is_btest_mode = false;
static bool is_console_mode = false;

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

  bool help = false;

  int argpos = 1;
  while(argpos < argc) {
    if(!strcmp(argv[argpos], "btest")) {
      is_test_mode = is_btest_mode = true;
#if RGSS >= 2
    } else if(!strcmp(argv[argpos], "test")) {
#else
    } else if(!strcmp(argv[argpos], "debug")) {
#endif
      is_test_mode = true;
#if RGSS == 3
    } else if(!strcmp(argv[argpos], "console")) {
      is_console_mode = true;
#endif
    } else if(!strcmp(argv[argpos], "-d") && argpos+1 < argc) {
      ++argpos;
      tryChdir(argv[argpos]);
    } else if(!strcmp(argv[argpos], "-h") || !strcmp(argv[argpos], "--help")) {
      help = true;
    } else {
      fprintf(stderr, "warning: unrecognized argument: %s\n", argv[argpos]);
    }
    ++argpos;
  }

  if(help) {
    fprintf(stderr,
#if RGSS == 3
        "Tapir-accordion: RGSS3 (RPG Maker VX Ace) compatible game engine\n"
#elif RGSS == 2
        "Tapir-violin: RGSS2 (RPG Maker VX) compatible game engine\n"
#else
        "Tapir-xylophone: RGSS (RPG Maker XP) compatible game engine\n"
#endif
        "\n"
        "Usage: ./tapir [-h] [-d DIR] [test] [btest] [console]\n"
        "    -h      show this help\n"
        "    -d DIR  move to DIR before running the game\n"
        "    test    enable test mode\n"
        "    btest   enable battle test mode\n"
#if RGSS == 3
        "    console show console (not yet implemented)\n"
#endif
      );
    return 0;
  }

  if(is_console_mode) {
    fprintf(stderr, "warning: ignored console flag\n");
  }

  initSDL();

  initArchive();

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

  deinitArchive();
  cleanupSDL();
  return state;
}

static void Init_RGSS(void) {
#if RGSS >= 2
  rb_gv_set("$TEST", is_test_mode ? Qtrue : Qfalse);
#else
  rb_gv_set("$DEBUG", is_test_mode ? Qtrue : Qfalse);
#endif
  rb_gv_set("$BTEST", is_btest_mode ? Qtrue : Qfalse);
  Init_RGSSError();
  Init_RGSSReset();
  Init_Rect();
  Init_Color();
  Init_Tone();
  Init_Table();
  Init_Bitmap();
  Init_Viewport();
  Init_Sprite();
  Init_Window();
  Init_Graphics();
  Init_Input();
  rb_define_global_function("load_data", rb_load_data, 1);
}
