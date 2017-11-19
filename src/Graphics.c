// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "Graphics.h"
#include <stdio.h>
#include <stdlib.h>
#include "Bitmap.h"
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
static int contiguous_skip_count = 0;
static bool reset_frame = true;
static double cap_debt = 0.0;
static Uint32 cap_last_ticks = 0;

static VALUE rb_graphics_s_update(VALUE klass);
#if RGSS >= 2
static VALUE rb_graphics_s_wait(VALUE klass, VALUE duration);
static VALUE rb_graphics_s_fadeout(VALUE klass, VALUE duration);
static VALUE rb_graphics_s_fadein(VALUE klass, VALUE duration);
#endif
static VALUE rb_graphics_s_freeze(VALUE klass);
static VALUE rb_graphics_s_transition(int argc, VALUE *argv, VALUE klass);
#if RGSS >= 2
static VALUE rb_graphics_s_snap_to_bitmap(VALUE klass);
#endif
static VALUE rb_graphics_s_frame_reset(VALUE klass);
#if RGSS >= 2
static VALUE rb_graphics_s_width(VALUE klass);
static VALUE rb_graphics_s_height(VALUE klass);
static VALUE rb_graphics_s_resize_screen(
    VALUE klass, VALUE width, VALUE height);
#endif
#if RGSS == 3
static VALUE rb_graphics_s_play_movie(VALUE klass, VALUE filename);
#endif
static VALUE rb_graphics_s_frame_rate(VALUE klass);
static VALUE rb_graphics_s_set_frame_rate(VALUE klass, VALUE newval);
static VALUE rb_graphics_s_frame_count(VALUE klass);
static VALUE rb_graphics_s_set_frame_count(VALUE klass, VALUE newval);
#if RGSS >= 2
static VALUE rb_graphics_s_brightness(VALUE klass);
static VALUE rb_graphics_s_set_brightness(VALUE klass, VALUE newval);
#endif

void Init_Graphics() {
  rb_mGraphics = rb_define_module("Graphics");
  rb_define_singleton_method(rb_mGraphics, "update", rb_graphics_s_update, 0);
#if RGSS >= 2
  rb_define_singleton_method(rb_mGraphics, "wait", rb_graphics_s_wait, 1);
  rb_define_singleton_method(rb_mGraphics, "fadeout",
      rb_graphics_s_fadeout, 1);
  rb_define_singleton_method(rb_mGraphics, "fadein", rb_graphics_s_fadein, 1);
#endif
  rb_define_singleton_method(rb_mGraphics, "freeze", rb_graphics_s_freeze, 0);
  rb_define_singleton_method(rb_mGraphics, "transition",
      rb_graphics_s_transition, -1);
#if RGSS >= 2
  rb_define_singleton_method(rb_mGraphics, "snap_to_bitmap",
      rb_graphics_s_snap_to_bitmap, 0);
#endif
  rb_define_singleton_method(rb_mGraphics,
      "frame_reset", rb_graphics_s_frame_reset, 0);
#if RGSS >= 2
  rb_define_singleton_method(rb_mGraphics, "width", rb_graphics_s_width, 0);
  rb_define_singleton_method(rb_mGraphics, "height", rb_graphics_s_height, 0);
  rb_define_singleton_method(rb_mGraphics, "resize_screen",
      rb_graphics_s_resize_screen, 2);
#endif
#if RGSS == 3
  rb_define_singleton_method(rb_mGraphics, "play_movie",
      rb_graphics_s_play_movie, 1);
#endif
  rb_define_singleton_method(rb_mGraphics,
      "frame_rate", rb_graphics_s_frame_rate, 0);
  rb_define_singleton_method(rb_mGraphics,
      "frame_rate=", rb_graphics_s_set_frame_rate, 1);
  rb_define_singleton_method(rb_mGraphics,
      "frame_count", rb_graphics_s_frame_count, 0);
  rb_define_singleton_method(rb_mGraphics,
      "frame_count=", rb_graphics_s_set_frame_count, 1);
#if RGSS >= 2
  rb_define_singleton_method(rb_mGraphics,
      "brightness", rb_graphics_s_brightness, 0);
  rb_define_singleton_method(rb_mGraphics,
      "brightness=", rb_graphics_s_set_brightness, 1);
#endif
}

static VALUE rb_graphics_s_update(VALUE klass) {
  (void) klass;

  event_loop();

  if(reset_frame) {
    // Reset frame counter;
    cap_debt = 0.0;
    cap_last_ticks = SDL_GetTicks();
    reset_frame = false;
  }

  // Cap too large debt.
  if(cap_debt > 1000.0) cap_debt = 1000.0;
  if(cap_debt < -1000.0) cap_debt = -1000.0;

  // If debt is too large, skip this frame.
  // However, we forcibly render frame sometimes.
  if(cap_debt < 1000.0 / frame_rate || contiguous_skip_count > 5) {
    renderSDL();
    contiguous_skip_count = 0;
  } else {
    ++contiguous_skip_count;
  }

  Uint32 current_ticks = SDL_GetTicks();
  cap_debt += (current_ticks - cap_last_ticks);
  cap_last_ticks = current_ticks;

  cap_debt -= 1000.0 / frame_rate;
  if(cap_debt < 0.0) {
    SDL_Delay(-cap_debt);
  }


  performance_frame_count++;
  if(performance_frame_count >= frame_rate * 10) {
    Uint32 elapsed = current_ticks - performance_last_ticks;
    fprintf(stderr, "FPS: %f\n",
        performance_frame_count * 1000.0 / (elapsed + 0.001));

    performance_frame_count = 0;
    performance_last_ticks = current_ticks;
  }

  frame_count++;

  // Wait until the window gets focused
  while((SDL_GetWindowFlags(window) & SDL_WINDOW_INPUT_FOCUS) == 0) {
    SDL_WaitEventTimeout(NULL, 1000);
    event_loop();
    cap_last_ticks = current_ticks = SDL_GetTicks();
  }

  return Qnil;
}

#if RGSS >= 2
static VALUE rb_graphics_s_wait(VALUE klass, VALUE duration) {
  int duration_i = NUM2INT(duration);
  for(int i = 0; i < duration_i; ++i) {
    rb_graphics_s_update(klass);
  }
  return Qnil;
}

static VALUE rb_graphics_s_fadeout(VALUE klass, VALUE duration) {
  int duration_i = NUM2INT(duration);
  for(int i = 0; i < duration_i; ++i) {
    window_brightness = (duration_i - i) * 255 / duration_i;
    rb_graphics_s_update(klass);
  }
  window_brightness = 0;
  return Qnil;
}

static VALUE rb_graphics_s_fadein(VALUE klass, VALUE duration) {
  int duration_i = NUM2INT(duration);
  for(int i = 0; i < duration_i; ++i) {
    window_brightness = i * 255 / duration_i;
    rb_graphics_s_update(klass);
  }
  window_brightness = 255;
  return Qnil;
}
#endif

static VALUE rb_graphics_s_freeze(VALUE klass) {
  (void) klass;
  freeze_screen();
  window_brightness = 0;
  return Qnil;
}

static VALUE rb_graphics_s_transition(int argc, VALUE *argv, VALUE klass) {
  if(argc > 3) {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 0..3)", argc);
  }
#if RGSS >= 2
  int duration = argc > 0 ? NUM2INT(argv[0]) : 10;
#else
  int duration = argc > 0 ? NUM2INT(argv[0]) : 8;
#endif
  const char *filename = argc > 1 ? StringValueCStr(argv[1]) : NULL;
  int vague = argc > 2 ? saturateInt32(NUM2INT(argv[2]), 0, 255) : 40;

  load_transition_image(filename, vague);

  for(int i = 0; i < duration; ++i) {
    window_brightness = i * 255 / duration;
    rb_graphics_s_update(klass);
  }
  window_brightness = 255;
  defreeze_screen();

  load_transition_image(NULL, 255);

  (void) vague;
  (void) filename;

  return Qnil;
}

#if RGSS >= 2
static VALUE rb_graphics_s_snap_to_bitmap(VALUE klass) {
  (void) klass;
  VALUE bitmap = rb_bitmap_new(window_width, window_height);
  struct Bitmap *bitmap_ptr = rb_bitmap_data_mut(bitmap);
  capturedRenderSDL(bitmap_ptr->surface);
  return bitmap;
}
#endif

static VALUE rb_graphics_s_frame_reset(VALUE klass) {
  (void) klass;
  reset_frame = true;
  return Qnil;
}

#if RGSS >= 2
static VALUE rb_graphics_s_width(VALUE klass) {
  (void) klass;

  return INT2NUM(window_width);
}

static VALUE rb_graphics_s_height(VALUE klass) {
  (void) klass;

  return INT2NUM(window_height);
}

static VALUE rb_graphics_s_resize_screen(
    VALUE klass, VALUE width, VALUE height) {
  (void) klass;
  int newwidth = saturateInt32(NUM2INT(width), 1, 640);
  int newheight = saturateInt32(NUM2INT(height), 1, 480);
  SDL_SetWindowSize(window, newwidth, newheight);
  SDL_GetWindowSize(window, &window_width, &window_height);
  return Qnil;
}
#endif

#if RGSS == 3
static VALUE rb_graphics_s_play_movie(VALUE klass, VALUE filename) {
  (void) klass;
  (void) filename;
  WARN_UNIMPLEMENTED("Graphics.play_movie");
  return Qnil;
}
#endif

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

#if RGSS >= 2
static VALUE rb_graphics_s_brightness(VALUE klass) {
  (void) klass;
  return INT2NUM(window_brightness);
}

static VALUE rb_graphics_s_set_brightness(VALUE klass, VALUE newval) {
  (void) klass;
  window_brightness = NUM2INT(newval);
  return newval;
}
#endif
