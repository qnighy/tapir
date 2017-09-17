#ifndef SPRITE_H
#define SPRITE_H

#include <stdbool.h>
#include <ruby.h>

#include "sdl_misc.h"

extern VALUE rb_cSprite;
void Init_Sprite(void);

struct Sprite {
  struct Renderable renderable;
  VALUE bitmap;
};

bool isSprite(VALUE obj);
struct Sprite *convertSprite(VALUE obj);
void rb_sprite_modify(VALUE obj);

void initSpriteSDL(void);
void deinitSpriteSDL(void);

#endif /* SPRITE_H */
