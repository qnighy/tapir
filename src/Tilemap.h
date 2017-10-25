// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef TILEMAP_H
#define TILEMAP_H

#include <stdbool.h>
#include <ruby.h>

#include "sdl_misc.h"

extern VALUE rb_cTilemap;
void Init_Tilemap(void);

struct Tilemap {
  struct Renderable renderable;
#if RGSS >= 2
  VALUE bitmaps, flags;
#else
  VALUE tileset, autotiles, priorities;
#endif
  VALUE map_data, flash_data, viewport;
  bool visible;
  int ox, oy;
  int autotile_tick;
};

bool rb_tilemap_data_p(VALUE obj);
const struct Tilemap *rb_tilemap_data(VALUE obj);
struct Tilemap *rb_tilemap_data_mut(VALUE obj);

void renderTilemaps(int z_min, int z_max);
void initTilemapSDL(void);
void deinitTilemapSDL(void);

#endif /* TILEMAP_H */
