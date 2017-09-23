#ifndef TILEMAP_H
#define TILEMAP_H

#include <stdbool.h>
#include <ruby.h>

#include "sdl_misc.h"

extern VALUE rb_cTilemap;
void Init_Tilemap(void);

struct Tilemap {
#if RGSS == 3
  VALUE bitmaps, flags;
#elif RGSS == 2
  VALUE bitmaps, passages;
#else
  VALUE tileset, autotiles, priorities;
#endif
  VALUE map_data, flash_data, viewport;
  bool disposed, visible;
  int ox, oy;
  int autotile_tick;
};

bool rb_tilemap_data_p(VALUE obj);
const struct Tilemap *rb_tilemap_data(VALUE obj);
struct Tilemap *rb_tilemap_data_mut(VALUE obj);

void renderTilemaps(void);
void initTilemapSDL(void);
void deinitTilemapSDL(void);

#endif /* TILEMAP_H */
