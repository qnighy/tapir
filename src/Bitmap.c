#include <SDL.h>
#include <SDL_image.h>
#include "Bitmap.h"
#include "RGSSError.h"
#include "openres.h"
#include "misc.h"

#if SDL_BYTEORDER == SDL_BIG_ENDIAN
#define RMASK 0xff000000
#define GMASK 0x00ff0000
#define BMASK 0x0000ff00
#define AMASK 0x000000ff
#define PIXELFORMAT_RGBA32 SDL_PIXELFORMAT_RGBA8888
#else
#define RMASK 0x000000ff
#define GMASK 0x0000ff00
#define BMASK 0x00ff0000
#define AMASK 0xff000000
#define PIXELFORMAT_RGBA32 SDL_PIXELFORMAT_ABGR8888
#endif

static void rb_bitmap_modify(VALUE obj);
static void bitmap_mark(struct Bitmap *ptr);
static void bitmap_free(struct Bitmap *ptr);
static VALUE bitmap_alloc(VALUE klass);

static VALUE rb_bitmap_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_bitmap_m_initialize_copy(VALUE self, VALUE orig);

static VALUE rb_bitmap_m_width(VALUE self);
static VALUE rb_bitmap_m_height(VALUE self);

VALUE rb_cBitmap;

/*
 * RGBA bitmap buffer.
 */
void Init_Bitmap(void) {
  rb_cBitmap = rb_define_class("Bitmap", rb_cObject);
  rb_define_alloc_func(rb_cBitmap, bitmap_alloc);
  rb_define_private_method(rb_cBitmap, "initialize",
      rb_bitmap_m_initialize, -1);
  rb_define_private_method(rb_cBitmap, "initialize_copy",
      rb_bitmap_m_initialize_copy, 1);
  rb_define_method(rb_cBitmap, "width", rb_bitmap_m_width, 0);
  rb_define_method(rb_cBitmap, "height", rb_bitmap_m_height, 0);
  // TODO: implement Bitmap#dispose
  // TODO: implement Bitmap#disposed?
  // TODO: implement Bitmap#rect
  // TODO: implement Bitmap#blt
  // TODO: implement Bitmap#stretch_blt
  // TODO: implement Bitmap#gradient_fill_rect
  // TODO: implement Bitmap#clear
  // TODO: implement Bitmap#clear_rect
  // TODO: implement Bitmap#get_pixel
  // TODO: implement Bitmap#set_pixel
  // TODO: implement Bitmap#hue_change
  // TODO: implement Bitmap#blur
  // TODO: implement Bitmap#radial_blur
  // TODO: implement Bitmap#draw_text
  // TODO: implement Bitmap#text_size
  // TODO: implement Bitmap#font
  // TODO: implement Bitmap#font=
}

bool isBitmap(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))bitmap_mark;
}

struct Bitmap *convertBitmap(VALUE obj) {
  Check_Type(obj, T_DATA);
  // Note: original RGSS doesn't check types.
  if(RDATA(obj)->dmark != (void(*)(void*))bitmap_mark) {
    rb_raise(rb_eTypeError,
        "can't convert %s into Bitmap",
        rb_class2name(rb_obj_class(obj)));
  }
  struct Bitmap *ret;
  Data_Get_Struct(obj, struct Bitmap, ret);
  return ret;
}

void bitmapBindTexture(struct Bitmap *ptr) {
  if(!ptr->texture_id) {
    glGenTextures(1, &ptr->texture_id);
    ptr->texture_invalidated = true;
  }
  glBindTexture(GL_TEXTURE_2D, ptr->texture_id);
  if(ptr->texture_invalidated) {
    SDL_LockSurface(ptr->surface);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, ptr->surface->w, ptr->surface->h,
        0, GL_RGBA, GL_UNSIGNED_BYTE, ptr->surface->pixels);
    SDL_UnlockSurface(ptr->surface);
    ptr->texture_invalidated = false;
  }
}

static void rb_bitmap_modify(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Bitmap");
}

static void bitmap_mark(struct Bitmap *ptr) {
  (void) ptr;
}

static void bitmap_free(struct Bitmap *ptr) {
  if(ptr->surface) SDL_FreeSurface(ptr->surface);
  if(ptr->texture_id) {
    glDeleteTextures(1, &ptr->texture_id);
  }
  xfree(ptr);
}

static VALUE bitmap_alloc(VALUE klass) {
  struct Bitmap *ptr = ALLOC(struct Bitmap);
  ptr->surface = NULL;
  ptr->texture_id = 0;
  ptr->texture_invalidated = true;
  VALUE ret = Data_Wrap_Struct(klass, bitmap_mark, bitmap_free, ptr);
  return ret;
}

/*
 * call-seq:
 *   Bitmap.new(filename)
 *   Bitmap.new(width, height)
 *
 * In the first form, loads an image from the path.
 * In the second form, creates an empty image with the given size.
 */
static VALUE rb_bitmap_m_initialize(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  switch(argc) {
    case 1:
      StringValue(argv[0]);
      Check_Type(argv[0], T_STRING);

      SDL_RWops *file = NULL;
      for(int i = 0; i < 4; ++i) {
        const char * const extensions[] = {"", ".png", ".jpg", ".bmp"};
        VALUE filename = rb_obj_dup(argv[0]);
        rb_str_cat2(filename, extensions[i]);
        file = openres(filename);
        if(file) break;
      }
      if(!file) {
        /* TODO: check error handling */
        rb_raise(rb_eRGSSError, "%s", SDL_GetError());
      }
      /* TODO: load from archive */
      /* TODO: limit file type */
      SDL_Surface *img = IMG_Load_RW(file, true);
      if(!img) {
        /* TODO: check error handling */
        rb_raise(rb_eRGSSError, "%s", IMG_GetError());
      }
      ptr->surface = SDL_ConvertSurfaceFormat(img, PIXELFORMAT_RGBA32, 0);
      SDL_FreeSurface(img);
      break;
    case 2:
      ptr->surface = SDL_CreateRGBSurface(
          0, NUM2INT(argv[0]), NUM2INT(argv[1]), 32,
          RMASK, GMASK, BMASK, AMASK);
      if(!ptr->surface) {
        /* TODO: check error handling */
        rb_raise(rb_eRGSSError, "Could not create surface: %s", SDL_GetError());
      }
      break;
    default:
      rb_raise(rb_eArgError,
          "wrong number of arguments (%d for 1..2)", argc);
      break;
  }
  return Qnil;
}

static VALUE rb_bitmap_m_initialize_copy(VALUE self, VALUE orig) {
  struct Bitmap *ptr = convertBitmap(self);
  struct Bitmap *orig_ptr = convertBitmap(orig);
  ptr->surface = SDL_CreateRGBSurface(
      0, orig_ptr->surface->w, orig_ptr->surface->h, 32,
      RMASK, GMASK, BMASK, AMASK);
  SDL_BlitSurface(orig_ptr->surface, NULL, ptr->surface, NULL);
  return Qnil;
}

static VALUE rb_bitmap_m_width(VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  return INT2NUM(ptr->surface->w);
}
static VALUE rb_bitmap_m_height(VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  return INT2NUM(ptr->surface->h);
}
