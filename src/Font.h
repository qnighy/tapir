// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef FONT_H
#define FONT_H

#include <stdbool.h>
#include <ruby.h>
#include <SDL.h>
#include <SDL_ttf.h>

extern VALUE rb_cFont;
extern void Init_Font(void);

struct Font {
  VALUE name;
  int size;
  bool bold, italic;
#if RGSS == 3
  bool outline;
#endif
#if RGSS >= 2
  bool shadow;
#endif
  VALUE color;
#if RGSS == 3
  VALUE out_color;
#endif
  TTF_Font *cache;
};

bool rb_font_data_p(VALUE obj);
const struct Font *rb_font_data(VALUE obj);
struct Font *rb_font_data_mut(VALUE obj);

VALUE rb_font_new(void);
void rb_font_set(VALUE self, VALUE other);

TTF_Font *rb_font_to_sdl(VALUE self);

#endif /* FONT_H */
