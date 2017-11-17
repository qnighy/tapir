// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef SPRITE_H
#define SPRITE_H

#include <stdbool.h>
#include <ruby.h>

#include "sdl_misc.h"

extern VALUE rb_cSprite;
void Init_Sprite(void);

struct Sprite {
  struct Renderable renderable;
  VALUE viewport, bitmap, src_rect, color, tone, flash_color;
  bool visible, mirror;
  int x, y, z, ox, oy;
#if RGSS >= 2
  int wave_amp, wave_length, wave_speed, bush_opacity;
#endif
  int bush_depth, opacity, blend_type;
  int flash_duration, flash_count;
  bool flash_is_nil;
  double zoom_x, zoom_y, angle;
#if RGSS >= 2
  double wave_phase;
#endif
};

bool rb_sprite_data_p(VALUE obj);
const struct Sprite *rb_sprite_data(VALUE obj);
struct Sprite *rb_sprite_data_mut(VALUE obj);

void initSpriteSDL(void);
void deinitSpriteSDL(void);

#endif /* SPRITE_H */
