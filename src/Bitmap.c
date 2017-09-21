#include <SDL.h>
#include <SDL_image.h>
#include "Bitmap.h"
#include "RGSSError.h"
#include "Color.h"
#include "Rect.h"
#include "Font.h"
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

static void bitmap_mark(struct Bitmap *ptr);
static void bitmap_free(struct Bitmap *ptr);
static VALUE bitmap_alloc(VALUE klass);

VALUE rb_bitmap_new(int width, int height) {
  VALUE ret = bitmap_alloc(rb_cBitmap);
  struct Bitmap *ptr = convertBitmap(ret);
  ptr->surface = SDL_CreateRGBSurface(
      0, width, height, 32,
      RMASK, GMASK, BMASK, AMASK);
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
static VALUE rb_bitmap_m_blt(int argc, VALUE *argv, VALUE self);
static VALUE rb_bitmap_m_fill_rect(int argc, VALUE *argv, VALUE self);
static VALUE rb_bitmap_m_clear(VALUE self);
#if RGSS >= 2
static VALUE rb_bitmap_m_clear_rect(int argc, VALUE *argv, VALUE self);
#endif
static VALUE rb_bitmap_m_get_pixel(VALUE self, VALUE x, VALUE y);
static VALUE rb_bitmap_m_set_pixel(VALUE self, VALUE x, VALUE y, VALUE color);
static VALUE rb_bitmap_m_draw_text(int argc, VALUE *argv, VALUE self);
static VALUE rb_bitmap_m_text_size(VALUE self, VALUE str);
static VALUE rb_bitmap_m_font(VALUE self);
static VALUE rb_bitmap_m_set_font(VALUE self, VALUE newval);

VALUE rb_cBitmap;

VALUE rb_bitmap_rect(VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
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
    SDL_LockSurface(ptr->surface);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, ptr->surface->w, ptr->surface->h,
        0, GL_RGBA, GL_UNSIGNED_BYTE, ptr->surface->pixels);
    SDL_UnlockSurface(ptr->surface);
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
  rb_define_method(rb_cBitmap, "blt", rb_bitmap_m_blt, -1);
  rb_define_method(rb_cBitmap, "fill_rect", rb_bitmap_m_fill_rect, -1);
  rb_define_method(rb_cBitmap, "clear", rb_bitmap_m_clear, 0);
#if RGSS >= 2
  rb_define_method(rb_cBitmap, "clear_rect", rb_bitmap_m_clear_rect, -1);
#endif
  rb_define_method(rb_cBitmap, "get_pixel", rb_bitmap_m_get_pixel, 2);
  rb_define_method(rb_cBitmap, "set_pixel", rb_bitmap_m_set_pixel, 3);
  rb_define_method(rb_cBitmap, "draw_text", rb_bitmap_m_draw_text, -1);
  rb_define_method(rb_cBitmap, "text_size", rb_bitmap_m_text_size, 1);
  rb_define_method(rb_cBitmap, "font", rb_bitmap_m_font, 0);
  rb_define_method(rb_cBitmap, "font=", rb_bitmap_m_set_font, 1);
  // TODO: implement Bitmap#dispose
  // TODO: implement Bitmap#disposed?
  // TODO: implement Bitmap#rect
  // TODO: implement Bitmap#blt
  // TODO: implement Bitmap#stretch_blt
  // TODO: implement Bitmap#gradient_fill_rect
  // TODO: implement Bitmap#hue_change
  // TODO: implement Bitmap#blur
  // TODO: implement Bitmap#radial_blur
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

void rb_bitmap_modify(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Bitmap");
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
  ptr->font = rb_font_new();
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
        file = openres(RSTRING_PTR(filename));
        if(file) break;
      }
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
  if(orig_ptr->surface) {
    ptr->surface = SDL_CreateRGBSurface(
        0, orig_ptr->surface->w, orig_ptr->surface->h, 32,
        RMASK, GMASK, BMASK, AMASK);
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
  struct Bitmap *ptr = convertBitmap(self);
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
  struct Bitmap *ptr = convertBitmap(self);
  return !ptr->surface ? Qtrue : Qfalse;
}

static VALUE rb_bitmap_m_width(VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  return INT2NUM(ptr->surface->w);
}

static VALUE rb_bitmap_m_height(VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  return INT2NUM(ptr->surface->h);
}

static VALUE rb_bitmap_m_blt(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;
  if(argc != 4 && argc != 5) {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 4..5)", argc);
  }
  int x = NUM2INT(argv[0]);
  int y = NUM2INT(argv[1]);
  struct Bitmap *src_ptr = convertBitmap(argv[2]);
  struct Rect *src_rect_ptr = convertRect(argv[3]);
  int opacity = argc > 4 ? saturateInt32(NUM2INT(argv[4]), 0, 255) : 255;

  if(!src_ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");

  if(opacity == 0) return Qnil;

  SDL_LockSurface(ptr->surface);
  SDL_LockSurface(src_ptr->surface);

  Uint32 *src_pixels = src_ptr->surface->pixels;
  int src_pitch = src_ptr->surface->pitch / 4;
  Uint32 *dst_pixels = ptr->surface->pixels;
  int dst_pitch = ptr->surface->pitch / 4;

  int xdiff = x - src_rect_ptr->x;
  int ydiff = y - src_rect_ptr->y;
  int xbegin = src_rect_ptr->x;
  if(xbegin < 0) xbegin = 0;
  if(xbegin < -xdiff) xbegin = -xdiff;
  int ybegin = src_rect_ptr->y;
  if(ybegin < 0) ybegin = 0;
  if(ybegin < -ydiff) ybegin = -ydiff;
  int xend = src_rect_ptr->x + src_rect_ptr->width;
  if(xend > src_ptr->surface->w) xend = src_ptr->surface->w;
  if(xend > ptr->surface->w - xdiff) xend = ptr->surface->w - xdiff;
  int yend = src_rect_ptr->y + src_rect_ptr->width;
  if(yend > src_ptr->surface->w) yend = src_ptr->surface->w;
  if(yend > ptr->surface->w - ydiff) yend = ptr->surface->w - ydiff;

  for(int sy = ybegin; sy < yend; ++sy) {
    for(int sx = xbegin; sx < xend; ++sx) {
      int dx = sx + xdiff;
      int dy = sy + ydiff;
      Uint32 src_rgba = src_pixels[sy * src_pitch + sx];
      Uint32 dst_rgba = dst_pixels[dy * dst_pitch + dx];
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
      Uint32 src_r = (src_rgba >> 24) & 0xff;
      Uint32 src_g = (src_rgba >> 16) & 0xff;
      Uint32 src_b = (src_rgba >> 8) & 0xff;
      Uint32 src_a = src_rgba & 0xff;
      Uint32 dst_r = (dst_rgba >> 24) & 0xff;
      Uint32 dst_g = (dst_rgba >> 16) & 0xff;
      Uint32 dst_b = (dst_rgba >> 8) & 0xff;
      Uint32 dst_a = dst_rgba & 0xff;
#else
      Uint32 src_r = src_rgba & 0xff;
      Uint32 src_g = (src_rgba >> 8) & 0xff;
      Uint32 src_b = (src_rgba >> 16) & 0xff;
      Uint32 src_a = (src_rgba >> 24) & 0xff;
      Uint32 dst_r = dst_rgba & 0xff;
      Uint32 dst_g = (dst_rgba >> 8) & 0xff;
      Uint32 dst_b = (dst_rgba >> 16) & 0xff;
      Uint32 dst_a = (dst_rgba >> 24) & 0xff;
#endif
      if(src_a == 0) continue;

      Uint32 src_t = 255 - src_a;
      Uint32 new_ag = dst_a * src_t + src_a * opacity;
      Uint32 new_a = new_ag / 255;
      Uint32 new_r =
        (dst_r * dst_a * src_t + src_r * src_a * opacity) / new_ag;
      Uint32 new_g =
        (dst_g * dst_a * src_t + src_g * src_a * opacity) / new_ag;
      Uint32 new_b =
        (dst_b * dst_a * src_t + src_b * src_a * opacity) / new_ag;
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
      Uint32 new_rgba = (new_r << 24) | (new_g << 16) | (new_b << 8) | new_a;
#else
      Uint32 new_rgba = new_r | (new_g << 8) | (new_b << 16) | (new_a << 24);
#endif
      dst_pixels[dy * dst_pitch + dx] = new_rgba;
    }
  }

  SDL_UnlockSurface(src_ptr->surface);
  SDL_UnlockSurface(ptr->surface);
  return Qnil;
}

static VALUE rb_bitmap_m_fill_rect(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  rb_bitmap_modify(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;

  SDL_Rect sdl_rect;
  struct Color *color_ptr;
  if(argc == 2) {
    struct Rect *rect_ptr = convertRect(argv[0]);
    sdl_rect.x = rect_ptr->x;
    sdl_rect.y = rect_ptr->y;
    sdl_rect.w = rect_ptr->width;
    sdl_rect.h = rect_ptr->height;
    color_ptr = convertColor(argv[1]);
  } else if(argc == 5) {
    sdl_rect.x = NUM2INT(argv[0]);
    sdl_rect.y = NUM2INT(argv[1]);
    sdl_rect.w = NUM2INT(argv[2]);
    sdl_rect.h = NUM2INT(argv[3]);
    color_ptr = convertColor(argv[4]);
  } else {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 2 or 5)", argc);
  }
  Uint32 red = (Uint8)color_ptr->red;
  Uint32 green = (Uint8)color_ptr->green;
  Uint32 blue = (Uint8)color_ptr->blue;
  Uint32 alpha = (Uint8)color_ptr->alpha;
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
  Uint32 color = (red << 24) | (green << 16) | (blue << 8) | alpha;
#else
  Uint32 color = red | (green << 8) | (blue << 16) | (alpha << 24);
#endif
  SDL_FillRect(ptr->surface, &sdl_rect, color);
  return Qnil;
}

static VALUE rb_bitmap_m_clear(VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  rb_bitmap_modify(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;
  SDL_FillRect(ptr->surface, NULL, 0x00000000);
  return Qnil;
}

#if RGSS >= 2
static VALUE rb_bitmap_m_clear_rect(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  rb_bitmap_modify(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;

  SDL_Rect sdl_rect;
  if(argc == 1) {
    struct Rect *rect_ptr = convertRect(argv[0]);
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
  struct Bitmap *ptr = convertBitmap(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  int xi = NUM2INT(x);
  int yi = NUM2INT(y);
  if(!(0 <= xi && xi < ptr->surface->w && 0 <= yi && yi < ptr->surface->h)) {
    return rb_color_new2();
  }
  SDL_LockSurface(ptr->surface);
  Uint8 *pixel =
    (Uint8*)ptr->surface->pixels + yi * ptr->surface->pitch + xi * 4;
  VALUE color = rb_color_new(
    pixel[0], pixel[1], pixel[2], pixel[3]);
  SDL_UnlockSurface(ptr->surface);
  return color;
}

static VALUE rb_bitmap_m_set_pixel(VALUE self, VALUE x, VALUE y, VALUE color) {
  struct Bitmap *ptr = convertBitmap(self);
  rb_bitmap_modify(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;
  int xi = NUM2INT(x);
  int yi = NUM2INT(y);
  struct Color *color_ptr = convertColor(color);
  if(!(0 <= xi && xi < ptr->surface->w && 0 <= yi && yi < ptr->surface->h)) {
    return Qnil;
  }
  SDL_LockSurface(ptr->surface);
  Uint8 *pixel =
    (Uint8*)ptr->surface->pixels + yi * ptr->surface->pitch + xi * 4;
  pixel[0] = color_ptr->red;
  pixel[1] = color_ptr->green;
  pixel[2] = color_ptr->blue;
  pixel[3] = color_ptr->alpha;
  SDL_UnlockSurface(ptr->surface);
  return Qnil;
}

static VALUE rb_bitmap_m_draw_text(int argc, VALUE *argv, VALUE self) {
  struct Bitmap *ptr = convertBitmap(self);
  rb_bitmap_modify(self);
  if(!ptr->surface) rb_raise(rb_eRGSSError, "disposed bitmap");
  ptr->texture_invalidated = true;

  VALUE str;
  SDL_Rect rect;
  int align = 0;
  if(argc == 2 || argc == 3) {
    struct Rect *rect_ptr = convertRect(argv[0]);
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

  struct Font *font_ptr = convertFont(ptr->font);
  TTF_Font *sdl_font = rb_font_to_sdl(ptr->font);

#if RGSS == 3
  if(font_ptr->outline) {
    TTF_SetFontOutline(sdl_font, 1);

    struct Color *font_out_color_ptr = convertColor(font_ptr->out_color);

    int out_width, out_height;
    TTF_SizeUTF8(sdl_font, cstr, &out_width, &out_height);

    SDL_Rect out_rect = rect;
    out_rect.x += (out_rect.w - out_width) * align / 2;
    out_rect.y--;
    out_rect.w = out_width;
    out_rect.h = out_height;

    SDL_Color outline_fg = {
      font_out_color_ptr->red,
      font_out_color_ptr->green,
      font_out_color_ptr->blue,
      font_out_color_ptr->alpha
    };
    SDL_Surface *rendered = TTF_RenderUTF8_Blended(sdl_font, cstr, outline_fg);
    SDL_SetSurfaceBlendMode(rendered, SDL_BLENDMODE_BLEND);
    SDL_BlitSurface(rendered, NULL, ptr->surface, &out_rect);
    SDL_FreeSurface(rendered);

    TTF_SetFontOutline(sdl_font, 0);
  }
#endif

  struct Color *font_color_ptr = convertColor(font_ptr->color);

  int width, height;
  TTF_SizeUTF8(sdl_font, cstr, &width, &height);

  rect.x += (rect.w - width) * align / 2;
  rect.w = width;
  rect.h = height;

  SDL_Color fg = {
    font_color_ptr->red,
    font_color_ptr->green,
    font_color_ptr->blue,
    font_color_ptr->alpha
  };
  SDL_Surface *rendered = TTF_RenderUTF8_Blended(sdl_font, cstr, fg);
  SDL_SetSurfaceBlendMode(rendered, SDL_BLENDMODE_BLEND);

  // TODO: implement scaling
  // TODO: implement shadow
  // TODO: implement outline
  SDL_BlitSurface(rendered, NULL, ptr->surface, &rect);
  SDL_FreeSurface(rendered);
  return Qnil;
}

static VALUE rb_bitmap_m_text_size(VALUE self, VALUE str) {
  struct Bitmap *ptr = convertBitmap(self);
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
  struct Bitmap *ptr = convertBitmap(self);
  return ptr->font;
}

static VALUE rb_bitmap_m_set_font(VALUE self, VALUE newval) {
  struct Bitmap *ptr = convertBitmap(self);
  rb_font_modify(self);
  rb_font_set(ptr->font, newval);
  return newval;
}
