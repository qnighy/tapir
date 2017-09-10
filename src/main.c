#include <stdio.h>
#include <stdlib.h>
#include <ruby.h>
#include <SDL.h>

#ifdef RUBY_GLOBAL_SETUP
RUBY_GLOBAL_SETUP
#endif

static int window_width = 640;
static int window_height = 480;
static SDL_Window *window = NULL;

static VALUE protected_main(VALUE data);
static void initSDL(void);
static void cleanupSDL(void);

int main() {
  int ruby_argc = 2;
  char *ruby_argv_array[] = {
    (char*)"ruby",
    NULL
  };
  char **ruby_argv = ruby_argv_array;
  int state = 0;

  initSDL();

#ifdef RUBY_INIT_STACK
  ruby_sysinit(&ruby_argc, &ruby_argv);
  {
    RUBY_INIT_STACK;
    ruby_init();
    rb_protect(protected_main, Qnil, &state);
  }
#else
  {
    (void) ruby_argc;
    (void) ruby_argv;
    ruby_init();
    rb_protect(protected_main, Qnil, &state);
  }
#endif

  SDL_Delay(1000);
  cleanupSDL();
  return state;
}

static VALUE protected_main(VALUE data) {
  (void) data;

  rb_eval_string("print \"Hello, world!\\n\"");
  rb_eval_string("p RUBY_VERSION");
  return Qnil;
}

static void initSDL() {
  if(SDL_Init(SDL_INIT_VIDEO)) {
    fprintf(stderr, "SDL_Init Error: %s\n", SDL_GetError());
    exit(1);
  }

  window = SDL_CreateWindow("hoge",
      SDL_WINDOWPOS_CENTERED,
      SDL_WINDOWPOS_CENTERED,
      window_width, window_height, SDL_WINDOW_SHOWN);
  if(!window) {
    fprintf(stderr, "SDL_CreateWindow Error: %s\n", SDL_GetError());
    SDL_Quit();
    exit(1);
  }
}

static void cleanupSDL() {
  SDL_DestroyWindow(window);
  SDL_Quit();
}
