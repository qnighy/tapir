#include <stdio.h>
#include <stdlib.h>
#include "Graphics.h"
#include "misc.h"
#include "sdl_misc.h"

VALUE rb_mGraphics;

#if RGSS >= 2
static int frame_rate = 60;
#else
static int frame_rate = 40;
#endif
static long frame_count = 0;
static int performance_frame_count = 0;
static Uint32 performance_last_ticks = 0;
static double cap_debt = 0.0;
static Uint32 cap_last_ticks = 0;

static VALUE rb_graphics_s_update(VALUE klass);
static VALUE rb_graphics_s_width(VALUE klass);
static VALUE rb_graphics_s_height(VALUE klass);
static VALUE rb_graphics_s_frame_reset(VALUE klass);
static VALUE rb_graphics_s_frame_rate(VALUE klass);
static VALUE rb_graphics_s_set_frame_rate(VALUE klass, VALUE newval);
static VALUE rb_graphics_s_frame_count(VALUE klass);
static VALUE rb_graphics_s_set_frame_count(VALUE klass, VALUE newval);

void Init_Graphics() {
  rb_mGraphics = rb_define_module("Graphics");
  rb_define_singleton_method(rb_mGraphics, "update", rb_graphics_s_update, 0);
  rb_define_singleton_method(rb_mGraphics, "width", rb_graphics_s_width, 0);
  rb_define_singleton_method(rb_mGraphics, "height", rb_graphics_s_height, 0);
  rb_define_singleton_method(rb_mGraphics,
      "frame_reset", rb_graphics_s_frame_reset, 0);
  rb_define_singleton_method(rb_mGraphics,
      "frame_rate", rb_graphics_s_frame_rate, 0);
  rb_define_singleton_method(rb_mGraphics,
      "frame_rate=", rb_graphics_s_set_frame_rate, 1);
  rb_define_singleton_method(rb_mGraphics,
      "frame_count", rb_graphics_s_frame_count, 0);
  rb_define_singleton_method(rb_mGraphics,
      "frame_count=", rb_graphics_s_set_frame_count, 1);
  // TODO: implement Graphics.wait
  // TODO: implement Graphics.fadeout
  // TODO: implement Graphics.fadein
  // TODO: implement Graphics.freeze
  // TODO: implement Graphics.transition
  // TODO: implement Graphics.snap_to_bitmap
  // TODO: implement Graphics.resize_screen
  // TODO: implement Graphics.play_movie
  // TODO: implement Graphics.brightness
  // TODO: implement Graphics.brightness=
}

static VALUE rb_graphics_s_update(VALUE klass) {
  (void) klass;

  event_loop();

  // If debt is too large, skip this frame.
  if(cap_debt < 1000.0 / frame_rate) {
    renderSDL();
  }

  Uint32 current_ticks = SDL_GetTicks();
  cap_debt += (current_ticks - cap_last_ticks);
  cap_last_ticks = current_ticks;

  cap_debt -= 1000.0 / frame_rate;
  if(cap_debt < 0.0) {
    SDL_Delay(-cap_debt);
  } else {
    cap_debt *= 0.999;
  }


  performance_frame_count++;
  if(performance_frame_count >= frame_rate) {
    Uint32 elapsed = current_ticks - performance_last_ticks;
    fprintf(stderr, "FPS: %f\n", frame_rate * 1000.0 / (elapsed + 0.001));

    performance_frame_count = 0;
    performance_last_ticks = current_ticks;
  }

  frame_count++;

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

static VALUE rb_graphics_s_frame_reset(VALUE klass) {
  (void) klass;
  cap_debt = 0.0;
  return Qnil;
}

static VALUE rb_graphics_s_frame_rate(VALUE klass) {
  (void) klass;
  return INT2NUM(frame_rate);
}

static VALUE rb_graphics_s_set_frame_rate(VALUE klass, VALUE newval) {
  (void) klass;
  frame_rate = saturateInt32(NUM2INT(newval), 10, 120);
  return newval;
}

static VALUE rb_graphics_s_frame_count(VALUE klass) {
  (void) klass;
  return LONG2NUM(frame_count);
}

static VALUE rb_graphics_s_set_frame_count(VALUE klass, VALUE newval) {
  (void) klass;
  frame_count = NUM2LONG(newval);
  return newval;
}
