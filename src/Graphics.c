#include <stdio.h>
#include <stdlib.h>
#include <ruby.h>
#include "Graphics.h"
#include "sdl_misc.h"

static VALUE rb_mGraphics;
static VALUE rb_graphics_update(VALUE self);

void Init_Graphics() {
  rb_mGraphics = rb_define_module("Graphics");
  rb_define_singleton_method(rb_mGraphics, "update", rb_graphics_update, 0);
}

static VALUE rb_graphics_update(VALUE self) {
  SDL_Event e;
  int quit = 0;

  (void) self;

  while(SDL_PollEvent(&e)) {
    switch(e.type) {
      case SDL_QUIT:
        quit = 1;
        break;
    }
  }
  /* TODO: Graphics.update: implement actual rendering */
  SDL_RenderClear(renderer);
  SDL_RenderPresent(renderer);
  SDL_Delay(1000 / 60);

  if(quit) {
    exit(0);
  }

  return Qnil;
}
