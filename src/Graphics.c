#include <stdio.h>
#include <stdlib.h>
#include <ruby.h>
#include "Graphics.h"
#include "sdl_misc.h"

VALUE rb_mGraphics;

static VALUE rb_graphics_s_update(VALUE self);
static VALUE rb_graphics_s_width(VALUE self);
static VALUE rb_graphics_s_height(VALUE self);

void Init_Graphics() {
  rb_mGraphics = rb_define_module("Graphics");
  rb_define_singleton_method(rb_mGraphics, "update", rb_graphics_s_update, 0);
  rb_define_singleton_method(rb_mGraphics, "width", rb_graphics_s_width, 0);
  rb_define_singleton_method(rb_mGraphics, "height", rb_graphics_s_height, 0);
  // TODO: implement Graphics.wait
  // TODO: implement Graphics.fadeout
  // TODO: implement Graphics.fadein
  // TODO: implement Graphics.freeze
  // TODO: implement Graphics.transition
  // TODO: implement Graphics.snap_to_bitmap
  // TODO: implement Graphics.frame_reset
  // TODO: implement Graphics.resize_screen
  // TODO: implement Graphics.play_movie
  // TODO: implement Graphics.frame_rate
  // TODO: implement Graphics.frame_rate=
  // TODO: implement Graphics.frame_count
  // TODO: implement Graphics.frame_count=
  // TODO: implement Graphics.brightness
  // TODO: implement Graphics.brightness=
}

static VALUE rb_graphics_s_update(VALUE self) {
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
  renderSDL();
  // TODO: use frame rate correctly
  SDL_Delay(1000 / 60);

  if(quit) {
    exit(0);
  }

  return Qnil;
}

static VALUE rb_graphics_s_width(VALUE self) {
  (void) self;

  return INT2NUM(window_width);
}

static VALUE rb_graphics_s_height(VALUE self) {
  (void) self;

  return INT2NUM(window_height);
}
