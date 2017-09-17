#ifndef BITMAP_H
#define BITMAP_H

#include <stdbool.h>
#include <ruby.h>
#define GL_GLEXT_PROTOTYPES
#include <SDL_opengl.h>
#include <SDL_opengl_glext.h>

extern VALUE rb_cBitmap;
extern void Init_Bitmap(void);

struct Bitmap {
  SDL_Surface *surface;
  GLuint texture_id;
  bool texture_invalidated;
};

bool isBitmap(VALUE obj);
struct Bitmap *convertBitmap(VALUE obj);
void rb_bitmap_modify(VALUE obj);

VALUE rb_bitmap_rect(VALUE self);
void bitmapBindTexture(struct Bitmap *ptr);

#endif /* BITMAP_H */
