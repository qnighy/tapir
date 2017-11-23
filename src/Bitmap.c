// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "Bitmap.h"
#include <SDL.h>
#include <SDL_image.h>
#include "RGSSError.h"
#include "Color.h"
#include "Rect.h"
#include "Font.h"
#include "openres.h"
#include "misc.h"
#include "sdl_misc.h"
#include "surface_misc.h"

static void bitmap_mark(struct Bitmap *ptr);
static void bitmap_free(struct Bitmap *ptr);
static VALUE bitmap_alloc(VALUE klass);

VALUE rb_bitmap_new(int width, int height) {
  VALUE ret = bitmap_alloc(rb_cBitmap);
  struct Bitmap *ptr = rb_bitmap_data_mut(ret);
  ptr->surface = create_rgba_surface(width, height);
  if(!ptr->surface) {
    /* TODO: check error handling */
    rb_raise(rb_eRGSSError, "Could not create surface: %s", SDL_GetError());
  }
  return ret;
}

static VALUE rb_bitmap_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_bitmap_m_initialize_copy(VALUE self, VALUE orig);

static VALUE rb_bitmap_m_dispose(VALUE self);
static VALUE rb_bitmap_m_disposed_p(VALUE self);
static VALUE rb_bitmap_m_width(VALUE self);
static VALUE rb_bitmap_m_height(VALUE self);
static VALUE rb_bitmap_m_rect(VALUE self);
static VALUE rb_bitmap_m_blt(int argc, VALUE *argv, VALUE self);
static VALUE rb_bitmap_m_stretch_blt(int argc, VALUE *argv, VALUE self);
static VALUE rb_bitmap_m_fill_rect(int argc, VALUE *argv, VALUE self);
#if RGSS >= 2
static VALUE rb_bitmap_m_gradient_fill_rect(int argc, VALUE *argv, VALUE self);
#endif
static VALUE rb_bitmap_m_clear(VALUE self);
#if RGSS >= 2
static VALUE rb_bitmap_m_clear_rect(int argc, VALUE *argv, VALUE self);
#endif
static VALUE rb_bitmap_m_get_pixel(VALUE self, VALUE x, VALUE y);
static VALUE rb_bitmap_m_set_pixel(VALUE self, VALUE x, VALUE y, VALUE color);
static VALUE rb_bitmap_m_hue_change(VALUE self, VALUE hue);
#if RGSS >= 2
static VALUE rb_bitmap_m_blur(VALUE self);
static VALUE rb_bitmap_m_radial_blur(VALUE self, VALUE angle, VALUE division);
#endif
static VALUE rb_bitmap_m_draw_text(int argc, VALUE *argv, VALUE self);
static VALUE rb_bitmap_m_text_size(VALUE self, VALUE str);
static VALUE rb_bitmap_m_font(VALUE self);
static VALUE rb_bitmap_m_set_font(VALUE self, VALUE newval);

VALUE rb_cBitmap;

VALUE rb_bitmap_rect(VALUE self) {
  const struct Bitmap *ptr = rb_bitmap_data(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  return rb_rect_new(0, 0, ptr->surface->w, ptr->surface->h);
}

void bitmapBindTexture(struct Bitmap *ptr) {
  if(!ptr->texture_id) {
    glGenTextures(1, &ptr->texture_id);
    ptr->texture_invalidated = true;
  }
  glBindTexture(GL_TEXTURE_2D, ptr->texture_id);
  if(ptr->texture_invalidated) {
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, ptr->surface->w, ptr->surface->h,
        0, GL_RGBA, GL_UNSIGNED_BYTE, ptr->surface->pixels);
    ptr->texture_invalidated = false;
  }
}

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
  rb_define_method(rb_cBitmap, "dispose", rb_bitmap_m_dispose, 0);
  rb_define_method(rb_cBitmap, "disposed?", rb_bitmap_m_disposed_p, 0);
  rb_define_method(rb_cBitmap, "width", rb_bitmap_m_width, 0);
  rb_define_method(rb_cBitmap, "height", rb_bitmap_m_height, 0);
  rb_define_method(rb_cBitmap, "rect", rb_bitmap_m_rect, 0);
  rb_define_method(rb_cBitmap, "blt", rb_bitmap_m_blt, -1);
  rb_define_method(rb_cBitmap, "stretch_blt", rb_bitmap_m_stretch_blt, -1);
  rb_define_method(rb_cBitmap, "fill_rect", rb_bitmap_m_fill_rect, -1);
#if RGSS >= 2
  rb_define_method(rb_cBitmap, "gradient_fill_rect",
      rb_bitmap_m_gradient_fill_rect, -1);
#endif
  rb_define_method(rb_cBitmap, "clear", rb_bitmap_m_clear, 0);
#if RGSS >= 2
  rb_define_method(rb_cBitmap, "clear_rect", rb_bitmap_m_clear_rect, -1);
#endif
  rb_define_method(rb_cBitmap, "get_pixel", rb_bitmap_m_get_pixel, 2);
  rb_define_method(rb_cBitmap, "set_pixel", rb_bitmap_m_set_pixel, 3);
  rb_define_method(rb_cBitmap, "hue_change", rb_bitmap_m_hue_change, 1);
#if RGSS >= 2
  rb_define_method(rb_cBitmap, "blur", rb_bitmap_m_blur, 0);
  rb_define_method(rb_cBitmap, "radial_blur", rb_bitmap_m_radial_blur, 2);
#endif
  rb_define_method(rb_cBitmap, "draw_text", rb_bitmap_m_draw_text, -1);
  rb_define_method(rb_cBitmap, "text_size", rb_bitmap_m_text_size, 1);
  rb_define_method(rb_cBitmap, "font", rb_bitmap_m_font, 0);
  rb_define_method(rb_cBitmap, "font=", rb_bitmap_m_set_font, 1);
}

bool rb_bitmap_data_p(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))bitmap_mark;
}

const struct Bitmap *rb_bitmap_data(VALUE obj) {
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

struct Bitmap *rb_bitmap_data_mut(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Bitmap");
  return (struct Bitmap *)rb_bitmap_data(obj);
}

static void bitmap_mark(struct Bitmap *ptr) {
  rb_gc_mark(ptr->font);
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
  ptr->font = Qnil;
  VALUE ret = Data_Wrap_Struct(klass, bitmap_mark, bitmap_free, ptr);
  ptr->font = rb_font_new();
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
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  switch(argc) {
    case 1:
      StringValue(argv[0]);
      Check_Type(argv[0], T_STRING);

      const char * const extensions[] = {"", ".png", ".jpg", ".bmp", NULL};
      VALUE filename = rb_str_new(RSTRING_PTR(argv[0]), RSTRING_LEN(argv[0]));
      SDL_RWops *file = openres_ext(filename, true, extensions);
      if(!file) {
        /* TODO: check error handling */
        rb_raise(rb_eRGSSError, "Error loading %s: %s",
            StringValueCStr(argv[0]),
            SDL_GetError());
      }
      /* TODO: limit file type */
      SDL_Surface *img = IMG_Load_RW(file, true);
      if(!img) {
        /* TODO: check error handling */
        rb_raise(rb_eRGSSError, "Error loading %s: %s",
            StringValueCStr(argv[0]),
            IMG_GetError());
      }
      ptr->surface = create_rgba_surface_from(img);
      break;
    case 2:
      ptr->surface = create_rgba_surface(NUM2INT(argv[0]), NUM2INT(argv[1]));
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
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  const struct Bitmap *orig_ptr = rb_bitmap_data(orig);
  if(orig_ptr->surface) {
    ptr->surface = create_rgba_surface(
        orig_ptr->surface->w, orig_ptr->surface->h);
    SDL_BlitSurface(orig_ptr->surface, NULL, ptr->surface, NULL);
  } else {
    ptr->surface = NULL;
  }
  if(ptr->texture_id) {
    glDeleteTextures(1, &ptr->texture_id);
    ptr->texture_id = 0;
    ptr->texture_invalidated = true;
  }
  rb_font_set(ptr->font, orig_ptr->font);
  return Qnil;
}

static VALUE rb_bitmap_m_dispose(VALUE self) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(ptr->texture_id) {
    glDeleteTextures(1, &ptr->texture_id);
    ptr->texture_id = 0;
    ptr->texture_invalidated = true;
  }
  SDL_FreeSurface(ptr->surface);
  ptr->surface = NULL;
  return Qnil;
}

static VALUE rb_bitmap_m_disposed_p(VALUE self) {
  const struct Bitmap *ptr = rb_bitmap_data(self);
  return !ptr->surface ? Qtrue : Qfalse;
}

static VALUE rb_bitmap_m_width(VALUE self) {
  const struct Bitmap *ptr = rb_bitmap_data(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  return INT2NUM(ptr->surface->w);
}

static VALUE rb_bitmap_m_height(VALUE self) {
  const struct Bitmap *ptr = rb_bitmap_data(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  return INT2NUM(ptr->surface->h);
}

static VALUE rb_bitmap_m_rect(VALUE self) {
  const struct Bitmap *ptr = rb_bitmap_data(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  return rb_rect_new(0, 0, ptr->surface->w, ptr->surface->h);
}

static void blt(
    SDL_Surface *dst, SDL_Surface *src,
    int dst_x, int dst_y, int dst_w, int dst_h,
    int src_x, int src_y, int src_w, int src_h, int opacity) {
  Uint32 *src_pixels = src->pixels;
  int src_pitch = src->pitch / 4;
  Uint32 *dst_pixels = dst->pixels;
  int dst_pitch = dst->pitch / 4;

  if(dst_w == 0 || dst_h == 0) return;

  int ratio_x = 256 * src_w / dst_w;
  int ratio_y = 256 * src_h / dst_h;
  if(ratio_x < 0) --src_x;
  if(ratio_y < 0) --src_y;

  for(int yi = 0; yi < dst_h; ++yi) {
    for(int xi = 0; xi < dst_w; ++xi) {
      int sx = src_x + xi * ratio_x / 256;
      int sy = src_y + yi * ratio_y / 256;
      int dx = dst_x + xi;
      int dy = dst_y + yi;
      if(!(0 <= sx && sx < src->w && 0 <= sy && sy < src->h)) {
        continue;
      }
      if(!(0 <= dx && dx < dst->w && 0 <= dy && dy < dst->h)) {
        continue;
      }
      Uint32 src_rgba = src_pixels[sy * src_pitch + sx];
      Uint32 dst_rgba = dst_pixels[dy * dst_pitch + dx];
      Uint32 src_r = RGBA32_R(src_rgba);
      Uint32 src_g = RGBA32_G(src_rgba);
      Uint32 src_b = RGBA32_B(src_rgba);
      Uint32 src_a = RGBA32_A(src_rgba);
      Uint32 dst_r = RGBA32_R(dst_rgba);
      Uint32 dst_g = RGBA32_G(dst_rgba);
      Uint32 dst_b = RGBA32_B(dst_rgba);
      Uint32 dst_a = RGBA32_A(dst_rgba);

      src_a = (src_a * opacity * 2 + 255) / (255 * 2);
      Uint32 denom = 255 * src_a + (255 - src_a) * dst_a;
      Uint32 new_a = denom / 255;
      Uint32 src_o;
      if(denom == 0) {
        src_o = 256;
      } else {
        src_o = src_a * 255 * 255 / denom;
        if(src_o > 0) ++src_o;
      }
      Uint32 dst_o = 256 - src_o;

      Uint32 new_r = (dst_r * dst_o + src_r * src_o) / 256;
      Uint32 new_g = (dst_g * dst_o + src_g * src_o) / 256;
      Uint32 new_b = (dst_b * dst_o + src_b * src_o) / 256;
      Uint32 new_rgba = RGBA32(new_r, new_g, new_b, new_a);
      dst_pixels[dy * dst_pitch + dx] = new_rgba;
    }
  }
}

static VALUE rb_bitmap_m_blt(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;
  if(argc != 4 && argc != 5) {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 4..5)", argc);
  }
  int x = NUM2INT(argv[0]);
  int y = NUM2INT(argv[1]);
  const struct Bitmap *src_ptr = rb_bitmap_data(argv[2]);
  const struct Rect *src_rect_ptr = rb_rect_data(argv[3]);
  if(!src_ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");

  int opacity = argc > 4 ? saturateInt32(NUM2INT(argv[4]), 0, 255) : 255;
  if(opacity == 0) return Qnil;

  blt(ptr->surface, src_ptr->surface,
      x, y, abs(src_rect_ptr->width), abs(src_rect_ptr->height),
      src_rect_ptr->x, src_rect_ptr->y,
      src_rect_ptr->width, src_rect_ptr->height, opacity);

  return Qnil;
}

static VALUE rb_bitmap_m_stretch_blt(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;
  if(argc != 3 && argc != 4) {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 3..4)", argc);
  }
  const struct Rect *dst_rect_ptr = rb_rect_data(argv[0]);
  const struct Bitmap *src_ptr = rb_bitmap_data(argv[1]);
  const struct Rect *src_rect_ptr = rb_rect_data(argv[2]);
  if(!src_ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");

  int opacity = argc > 3 ? saturateInt32(NUM2INT(argv[3]), 0, 255) : 255;
  if(opacity == 0) return Qnil;

  blt(ptr->surface, src_ptr->surface,
      dst_rect_ptr->x, dst_rect_ptr->y,
      dst_rect_ptr->width, dst_rect_ptr->height,
      src_rect_ptr->x, src_rect_ptr->y,
      src_rect_ptr->width, src_rect_ptr->height, opacity);

  return Qnil;
}

static VALUE rb_bitmap_m_fill_rect(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;

  SDL_Rect sdl_rect;
  const struct Color *color_ptr;
  if(argc == 2) {
    const struct Rect *rect_ptr = rb_rect_data(argv[0]);
    sdl_rect.x = rect_ptr->x;
    sdl_rect.y = rect_ptr->y;
    sdl_rect.w = rect_ptr->width;
    sdl_rect.h = rect_ptr->height;
    color_ptr = rb_color_data(argv[1]);
  } else if(argc == 5) {
    sdl_rect.x = NUM2INT(argv[0]);
    sdl_rect.y = NUM2INT(argv[1]);
    sdl_rect.w = NUM2INT(argv[2]);
    sdl_rect.h = NUM2INT(argv[3]);
    color_ptr = rb_color_data(argv[4]);
  } else {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 2 or 5)", argc);
  }
  Uint32 red = (Uint8)color_ptr->red;
  Uint32 green = (Uint8)color_ptr->green;
  Uint32 blue = (Uint8)color_ptr->blue;
  Uint32 alpha = (Uint8)color_ptr->alpha;
  Uint32 color = RGBA32(red, green, blue, alpha);
  SDL_FillRect(ptr->surface, &sdl_rect, color);
  return Qnil;
}

#if RGSS >= 2
static VALUE rb_bitmap_m_gradient_fill_rect(
    int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;

  SDL_Rect sdl_rect;
  const struct Color *color1_ptr, *color2_ptr;
  bool vertical = false;
  if(argc == 3 || argc == 4) {
    const struct Rect *rect_ptr = rb_rect_data(argv[0]);
    sdl_rect.x = rect_ptr->x;
    sdl_rect.y = rect_ptr->y;
    sdl_rect.w = rect_ptr->width;
    sdl_rect.h = rect_ptr->height;
    color1_ptr = rb_color_data(argv[1]);
    color2_ptr = rb_color_data(argv[2]);
    if(argc == 4) vertical = RTEST(argv[3]);
  } else if(argc == 6 || argc == 7) {
    sdl_rect.x = NUM2INT(argv[0]);
    sdl_rect.y = NUM2INT(argv[1]);
    sdl_rect.w = NUM2INT(argv[2]);
    sdl_rect.h = NUM2INT(argv[3]);
    color1_ptr = rb_color_data(argv[4]);
    color2_ptr = rb_color_data(argv[5]);
    // Note: this should be RTEST(argv[6]),
    // but original RGSS wrongly uses RTEST(argv[3]);
    if(argc == 7) vertical = RTEST(argv[3]);
  } else {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 3..4 or 6..7)", argc);
  }
  Uint32 red1 = (Uint8)color1_ptr->red;
  Uint32 green1 = (Uint8)color1_ptr->green;
  Uint32 blue1 = (Uint8)color1_ptr->blue;
  Uint32 alpha1 = (Uint8)color1_ptr->alpha;
  Uint32 red2 = (Uint8)color2_ptr->red;
  Uint32 green2 = (Uint8)color2_ptr->green;
  Uint32 blue2 = (Uint8)color2_ptr->blue;
  Uint32 alpha2 = (Uint8)color2_ptr->alpha;
  Uint32 *pixels = ptr->surface->pixels;
  int pitch = ptr->surface->pitch / 4;
  int width = ptr->surface->w;
  int height = ptr->surface->h;
  int l = vertical ? sdl_rect.h : sdl_rect.w;
  if(l > 1) --l;
  for(int yi = 0; yi < sdl_rect.h; ++yi) {
    for(int xi = 0; xi < sdl_rect.w; ++xi) {
      int y = sdl_rect.y + yi;
      int x = sdl_rect.x + xi;
      if(!(0 <= x && x < width && 0 <= y && y < height)) {
        continue;
      }
      int i = vertical ? yi : xi;
      Uint32 red = red1 + (int)(red2 - red1) * i / l;
      Uint32 green = green1 + (int)(green2 - green1) * i / l;
      Uint32 blue = blue1 + (int)(blue2 - blue1) * i / l;
      Uint32 alpha = alpha1 + (int)(alpha2 - alpha1) * i / l;
      Uint32 color = RGBA32(red, green, blue, alpha);
      pixels[y * pitch + x] = color;
    }
  }
  return Qnil;
}
#endif

static VALUE rb_bitmap_m_clear(VALUE self) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;
  SDL_FillRect(ptr->surface, NULL, 0x00000000);
  return Qnil;
}

#if RGSS >= 2
static VALUE rb_bitmap_m_clear_rect(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;

  SDL_Rect sdl_rect;
  if(argc == 1) {
    const struct Rect *rect_ptr = rb_rect_data(argv[0]);
    sdl_rect.x = rect_ptr->x;
    sdl_rect.y = rect_ptr->y;
    sdl_rect.w = rect_ptr->width;
    sdl_rect.h = rect_ptr->height;
  } else if(argc == 4) {
    sdl_rect.x = NUM2INT(argv[0]);
    sdl_rect.y = NUM2INT(argv[1]);
    sdl_rect.w = NUM2INT(argv[2]);
    sdl_rect.h = NUM2INT(argv[3]);
  } else {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 1 or 4)", argc);
  }
  SDL_FillRect(ptr->surface, &sdl_rect, 0x00000000);
  return Qnil;
}
#endif

static VALUE rb_bitmap_m_get_pixel(VALUE self, VALUE x, VALUE y) {
  const struct Bitmap *ptr = rb_bitmap_data(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  int xi = NUM2INT(x);
  int yi = NUM2INT(y);
  if(!(0 <= xi && xi < ptr->surface->w && 0 <= yi && yi < ptr->surface->h)) {
    return rb_color_new2();
  }
  Uint8 *pixel =
    (Uint8*)ptr->surface->pixels + yi * ptr->surface->pitch + xi * 4;
  VALUE color = rb_color_new(
    pixel[0], pixel[1], pixel[2], pixel[3]);
  return color;
}

static VALUE rb_bitmap_m_set_pixel(VALUE self, VALUE x, VALUE y, VALUE color) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;
  int xi = NUM2INT(x);
  int yi = NUM2INT(y);
  const struct Color *color_ptr = rb_color_data(color);
  if(!(0 <= xi && xi < ptr->surface->w && 0 <= yi && yi < ptr->surface->h)) {
    return Qnil;
  }
  Uint8 *pixel =
    (Uint8*)ptr->surface->pixels + yi * ptr->surface->pitch + xi * 4;
  pixel[0] = color_ptr->red;
  pixel[1] = color_ptr->green;
  pixel[2] = color_ptr->blue;
  pixel[3] = color_ptr->alpha;
  return Qnil;
}

static VALUE rb_bitmap_m_hue_change(VALUE self, VALUE hue) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;
  SDL_Surface *surface = ptr->surface;
  int w = surface->w;
  int h = surface->h;
  int pitch = surface->pitch / 4;
  Uint32 *pixels = surface->pixels;
  int hue_i = NUM2INT(hue);

  if(hue_i == 0) return Qnil;

  for(int y = 0; y < h; ++y) {
    for(int x = 0; x < w; ++x) {
      Uint32 rgba = pixels[y * pitch + x];
      int r = RGBA32_R(rgba);
      int g = RGBA32_G(rgba);
      int b = RGBA32_B(rgba);
      int a = RGBA32_A(rgba);
      int minval = r;
      if(minval > g) minval = g;
      if(minval > b) minval = b;
      int maxval = r;
      if(maxval < g) maxval = g;
      if(maxval < b) maxval = b;
      int dif = maxval - minval;
      if(dif == 0) continue;
      int hue2;
      if(maxval == r) {
        hue2 = (g - b) * 60 / dif;
        if(hue2 < 0) hue2 += 360;
      } else if(maxval == g) {
        hue2 = (b - r) * 60 / dif + 120;
      } else {
        hue2 = (r - g) * 60 / dif + 240;
      }

      hue2 = (hue2 + hue_i) % 360;
      if(hue2 < 0) hue2 += 360;

      if(hue2 < 60) {
        // r > g > b
        r = maxval;
        g = minval + dif * hue2 / 60;
        b = minval;
      } else if(hue2 < 120) {
        // g > r > b
        r = minval + dif * (120 - hue2) / 60;
        g = maxval;
        b = minval;
      } else if(hue2 < 180) {
        // g > b > r
        r = minval;
        g = maxval;
        b = minval + dif * (hue2 - 120) / 60;
      } else if(hue2 < 240) {
        // b > g > r
        r = minval;
        g = minval + dif * (240 - hue2) / 60;
        b = maxval;
      } else if(hue2 < 300) {
        // b > r > g
        r = minval + dif * (hue2 - 240) / 60;
        g = minval;
        b = maxval;
      } else {
        // r > b > g
        r = maxval;
        g = minval;
        b = minval + dif * (360 - hue2) / 60;
      }

      rgba = RGBA32(r, g, b, a);
      pixels[y * pitch + x] = rgba;
    }
  }
  return Qnil;
}

#if RGSS >= 2
static VALUE rb_bitmap_m_blur(VALUE self) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;

  SDL_Surface *orig = ptr->surface;
  int w = orig->w;
  int h = orig->h;
  int orig_pitch = orig->pitch / 4;
  SDL_Surface *dest = create_rgba_surface(w, h);
  int dest_pitch = dest->pitch / 4;

  Uint32 *orig_pixels = orig->pixels;
  Uint32 *dest_pixels = dest->pixels;
  for(int y = 0; y < h; ++y) {
    for(int x = 0; x < w; ++x) {
      int sum_r = 0, sum_g = 0, sum_b = 0, sum_a = 0;
      for(int yp = -1; yp <= 1; ++yp) {
        for(int xp = -1; xp <= 1; ++xp) {
          int ys = y + yp;
          int xs = x + xp;
          ys = ys < 0 ? 0 : ys >= h ? h-1 : ys;
          xs = xs < 0 ? 0 : xs >= w ? w-1 : xs;
          Uint32 src_rgba = orig_pixels[ys * orig_pitch + xs];
          sum_r += RGBA32_R(src_rgba);
          sum_g += RGBA32_G(src_rgba);
          sum_b += RGBA32_B(src_rgba);
          sum_a += RGBA32_A(src_rgba);
        }
      }
      int red = sum_r / 9;
      int green = sum_g / 9;
      int blue = sum_b / 9;
      int alpha = sum_a / 9;
      Uint32 color = RGBA32(red, green, blue, alpha);
      dest_pixels[y * dest_pitch + x] = color;
    }
  }

  ptr->surface = dest;
  SDL_FreeSurface(orig);
  return Qnil;
}

static VALUE rb_bitmap_m_radial_blur(VALUE self, VALUE angle, VALUE division) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;

  int angle_i = NUM2INT(angle);
  double angle_rad = angle_i * (3.1415926535897932384 / 180.0);
  int division_i = NUM2INT(division);
  if(division_i < 2) return Qnil;

  SDL_Surface *orig = ptr->surface;
  int w = orig->w;
  int h = orig->h;
  int orig_pitch = orig->pitch / 4;
  SDL_Surface *dest = create_rgba_surface(w, h);
  int dest_pitch = dest->pitch / 4;

  Uint32 *orig_pixels = orig->pixels;
  Uint32 *dest_pixels = dest->pixels;

  double *sins = malloc(sizeof(*sins) * division);
  double *coss = malloc(sizeof(*coss) * division);
  for(int i = 0; i < division_i; ++i) {
    double theta = angle_rad * ((double)i / (division_i - 1) - 0.5);
    sins[i] = sin(theta);
    coss[i] = cos(theta);
  }
  double centerx = (w - 1) * 0.5;
  double centery = (h - 1) * 0.5;

  for(int y = 0; y < h; ++y) {
    for(int x = 0; x < w; ++x) {
      int sum_r = 0, sum_g = 0, sum_b = 0, sum_a = 0;
      for(int i = 0; i < division_i; ++i) {
        int xrel = x - centerx;
        int yrel = y - centery;
        int xs = xrel * coss[i] - yrel * sins[i] + centerx + 0.5;
        int ys = xrel * sins[i] + yrel * coss[i] + centery + 0.5;
        ys = ys < 0 ? -ys : ys >= h ? h*2-1-ys : ys;
        xs = xs < 0 ? -xs : xs >= w ? w*2-1-xs : xs;
        ys = ys < 0 ? 0 : ys >= h ? h-1 : ys;
        xs = xs < 0 ? 0 : xs >= w ? w-1 : xs;
        Uint32 src_rgba = orig_pixels[ys * orig_pitch + xs];
        sum_r += RGBA32_R(src_rgba);
        sum_g += RGBA32_G(src_rgba);
        sum_b += RGBA32_B(src_rgba);
        sum_a += RGBA32_A(src_rgba);
      }
      int red = sum_r / division_i;
      int green = sum_g / division_i;
      int blue = sum_b / division_i;
      int alpha = sum_a / division_i;
      Uint32 color = RGBA32(red, green, blue, alpha);
      dest_pixels[y * dest_pitch + x] = color;
    }
  }
  free(sins);
  free(coss);

  ptr->surface = dest;
  SDL_FreeSurface(orig);
  return Qnil;
}
#endif

static VALUE rb_bitmap_m_draw_text(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;

  VALUE str;
  SDL_Rect rect;
  int align = 0;
  if(argc == 2 || argc == 3) {
    const struct Rect *rect_ptr = rb_rect_data(argv[0]);
    rect.x = rect_ptr->x;
    rect.y = rect_ptr->y;
    rect.w = rect_ptr->width;
    rect.h = rect_ptr->height;
    str = argv[1];
    if(argc == 3) align = NUM2INT(argv[2]);
  } else if(argc == 5 || argc == 6) {
    rect.x = NUM2INT(argv[0]);
    rect.y = NUM2INT(argv[1]);
    rect.w = NUM2INT(argv[2]);
    rect.h = NUM2INT(argv[3]);
    str = argv[4];
    if(argc == 6) align = NUM2INT(argv[5]);
  } else {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 2..3 or 5..6)", argc);
  }

#if RGSS >= 2
  if(TYPE(str) != T_STRING) {
    str = rb_funcall(str, rb_intern("to_s"), 0);
  }
#endif
  const char *cstr = StringValueCStr(str);

  if(cstr[0] == '\0') {
    // cstr == "": return early to avoid SDL error.
    return Qnil;
  }

  const struct Font *font_ptr = rb_font_data(ptr->font);
  TTF_Font *sdl_font = rb_font_to_sdl(ptr->font);

  const struct Color *font_color_ptr = rb_color_data(font_ptr->color);
  SDL_Color fg_color = {
    font_color_ptr->red,
    font_color_ptr->green,
    font_color_ptr->blue,
    font_color_ptr->alpha
  };
  SDL_Surface *fg_rendered = TTF_RenderUTF8_Blended(sdl_font, cstr, fg_color);
  if(!fg_rendered) {
    fprintf(stderr, "Error rendering text: %s\n", SDL_GetError());
    fprintf(stderr, "cstr = %s\n", cstr);
    return Qnil;
  }

  fg_rendered = create_rgba_surface_from(fg_rendered);

  int fg_width = fg_rendered->w;
  int fg_height = fg_rendered->h;

  int fg_stretch_width;
  if(rect.w < fg_width * 3 / 5) {
    fg_stretch_width = fg_width * 3 / 5;
  } else if(rect.w < fg_width) {
    fg_stretch_width = rect.w;
  } else {
    fg_stretch_width = fg_width;
  }
  rect.x += (rect.w - fg_stretch_width) * align / 2;
  if(rect.h > fg_height) rect.y += (rect.h - fg_height) / 2;
  rect.w = fg_stretch_width;
  rect.h = fg_height;

#if RGSS == 3
  if(font_ptr->outline) {
    TTF_SetFontOutline(sdl_font, 1);

    const struct Color *font_out_color_ptr =
      rb_color_data(font_ptr->out_color);
    SDL_Color out_color = {
      font_out_color_ptr->red,
      font_out_color_ptr->green,
      font_out_color_ptr->blue,
      font_out_color_ptr->alpha
    };
    SDL_Surface *out_rendered =
      TTF_RenderUTF8_Blended(sdl_font, cstr, out_color);
    if(!out_rendered) {
      fprintf(stderr, "Error rendering text outline: %s\n", SDL_GetError());
      SDL_FreeSurface(fg_rendered);
      return Qnil;
    }
    out_rendered = create_rgba_surface_from(out_rendered);

    int out_width = out_rendered->w;
    int out_height = out_rendered->h;

    SDL_Rect out_rect = rect;
    // out_rect.x -= (out_width - rect.w) / 2;
    // out_rect.y -= (out_height - rect.h) / 2;
    --out_rect.x;
    --out_rect.y;
    out_rect.w += out_width - fg_width;
    out_rect.h = out_height;

    blt(ptr->surface, out_rendered,
        out_rect.x, out_rect.y, out_rect.w, out_rect.h,
        0, 0, out_width, out_height, font_out_color_ptr->alpha);
    SDL_FreeSurface(out_rendered);

    TTF_SetFontOutline(sdl_font, 0);
  }
#endif

#if RGSS >= 2
  if(font_ptr->shadow) {
    SDL_Color shadow_color = { 0, 0, 0, 255 };
    SDL_Surface *shadow_rendered =
      TTF_RenderUTF8_Blended(sdl_font, cstr, shadow_color);
    if(!shadow_rendered) {
      fprintf(stderr, "Error rendering text shadow: %s\n", SDL_GetError());
      SDL_FreeSurface(fg_rendered);
      return Qnil;
    }
    shadow_rendered = create_rgba_surface_from(shadow_rendered);

    SDL_Rect shadow_rect = rect;
    ++shadow_rect.x;
    ++shadow_rect.y;

    blt(ptr->surface, shadow_rendered,
        shadow_rect.x, shadow_rect.y, shadow_rect.w, shadow_rect.h,
        0, 0, fg_width, fg_height, font_color_ptr->alpha);
    SDL_FreeSurface(shadow_rendered);
  }
#endif

  blt(ptr->surface, fg_rendered,
      rect.x, rect.y, rect.w, rect.h,
      0, 0, fg_width, fg_height, font_color_ptr->alpha);
  SDL_FreeSurface(fg_rendered);
  return Qnil;
}

static VALUE rb_bitmap_m_text_size(VALUE self, VALUE str) {
  const struct Bitmap *ptr = rb_bitmap_data(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
#if RGSS >= 2
  if(TYPE(str) != T_STRING) {
    str = rb_funcall(str, rb_intern("to_s"), 0);
  }
#endif
  const char *cstr = StringValueCStr(str);

  TTF_Font *font = rb_font_to_sdl(ptr->font);
  int width, height;
  TTF_SizeUTF8(font, cstr, &width, &height);
  return rb_rect_new(0, 0, width, height);
}

static VALUE rb_bitmap_m_font(VALUE self) {
  const struct Bitmap *ptr = rb_bitmap_data(self);
  return ptr->font;
}

static VALUE rb_bitmap_m_set_font(VALUE self, VALUE newval) {
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  rb_font_set(ptr->font, newval);
  return newval;
}
