#ifndef SPRITE_H
#define SPRITE_H

#include <ruby.h>

#include "sdl_misc.h"

extern VALUE rb_cSprite;
void Init_Sprite(void);

void initSpriteSDL(void);
void deinitSpriteSDL(void);

#endif /* SPRITE_H */
