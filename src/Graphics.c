#include <stdio.h>
#include <stdlib.h>
#include "Graphics.h"
#include "sdl_misc.h"

VALUE rb_mGraphics;

#if RGSS >= 2
static int frame_rate = 60;
#else
static int frame_rate = 40;
#endif
static int performance_frame_count = 0;
static Uint32 performance_last_ticks = 0;

static VALUE rb_graphics_s_update(VALUE klass);
static VALUE rb_graphics_s_width(VALUE klass);
static VALUE rb_graphics_s_height(VALUE klass);

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

static VALUE rb_graphics_s_update(VALUE klass) {
  (void) klass;

  event_loop();

  renderSDL();
  // TODO: use frame rate correctly
  SDL_Delay(1000 / frame_rate);

  performance_frame_count++;
  if(performance_frame_count >= frame_rate) {
    Uint32 current_ticks = SDL_GetTicks();
    Uint32 elapsed = current_ticks - performance_last_ticks;
    fprintf(stderr, "FPS: %f\n", frame_rate * 1000.0 / (elapsed + 0.001));

    performance_frame_count = 0;
    performance_last_ticks = current_ticks;
  }

  return Qnil;
}

static VALUE rb_graphics_s_width(VALUE klass) {
  (void) klass;

  return INT2NUM(window_width);
}

static VALUE rb_graphics_s_height(VALUE klass) {
  (void) klass;

  return INT2NUM(window_height);
}
