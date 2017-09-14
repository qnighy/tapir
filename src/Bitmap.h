#ifndef BITMAP_H
#define BITMAP_H

#include <stdbool.h>
#include <ruby.h>

extern VALUE rb_cBitmap;
extern void Init_Bitmap(void);

struct Bitmap {
  SDL_Surface *surface;
};

bool isBitmap(VALUE obj);
struct Bitmap *convertBitmap(VALUE obj);

#endif /* BITMAP_H */
