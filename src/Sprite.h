#ifndef SPRITE_H
#define SPRITE_H

#include <stdbool.h>
#include <ruby.h>

#include "sdl_misc.h"

extern VALUE rb_cSprite;
void Init_Sprite(void);

struct Sprite {
  struct Renderable renderable;
  VALUE bitmap, src_rect, color, tone;
  bool disposed, visible, mirror;
  int x, y, ox, oy;
#if RGSS >= 2
  int wave_amp, wave_length, wave_speed, bush_opacity;
#endif
  int bush_depth, opacity, blend_type;
  double zoom_x, zoom_y, angle;
#if RGSS >= 2
  double wave_phase;
#endif
};

bool isSprite(VALUE obj);
struct Sprite *convertSprite(VALUE obj);
void rb_sprite_modify(VALUE obj);

void initSpriteSDL(void);
void deinitSpriteSDL(void);

#endif /* SPRITE_H */
