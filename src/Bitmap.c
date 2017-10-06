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
  struct Bitmap *ptr = rb_bitmap_data_mut(ret);
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
static VALUE rb_bitmap_m_stretch_blt(int argc, VALUE *argv, VALUE self);
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
  rb_define_method(rb_cBitmap, "stretch_blt", rb_bitmap_m_stretch_blt, -1);
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
  // TODO: implement Bitmap#gradient_fill_rect
  // TODO: implement Bitmap#hue_change
  // TODO: implement Bitmap#blur
  // TODO: implement Bitmap#radial_blur
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

      SDL_RWops *file = NULL;
      for(int i = 0; i < 4; ++i) {
        const char * const extensions[] = {"", ".png", ".jpg", ".bmp"};
        VALUE filename = rb_str_dup(argv[0]);
        rb_str_cat2(filename, extensions[i]);
        file = openres(filename, true);
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
  struct Bitmap *ptr = rb_bitmap_data_mut(self);
  const struct Bitmap *orig_ptr = rb_bitmap_data(orig);
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

static void blt(
    SDL_Surface *dst, SDL_Surface *src,
    int dst_x, int dst_y, int dst_w, int dst_h,
    int src_x, int src_y, int src_w, int src_h, int opacity) {
  SDL_LockSurface(dst);
  SDL_LockSurface(src);

  Uint32 *src_pixels = src->pixels;
  int src_pitch = src->pitch / 4;
  Uint32 *dst_pixels = dst->pixels;
  int dst_pitch = dst->pitch / 4;

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
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
      Uint32 new_rgba = (new_r << 24) | (new_g << 16) | (new_b << 8) | new_a;
#else
      Uint32 new_rgba = new_r | (new_g << 8) | (new_b << 16) | (new_a << 24);
#endif
      dst_pixels[dy * dst_pitch + dx] = new_rgba;
    }
  }

  SDL_UnlockSurface(src);
  SDL_UnlockSurface(dst);
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
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
  Uint32 color = (red << 24) | (green << 16) | (blue << 8) | alpha;
#else
  Uint32 color = red | (green << 8) | (blue << 16) | (alpha << 24);
#endif
  SDL_FillRect(ptr->surface, &sdl_rect, color);
  return Qnil;
}

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
  SDL_LockSurface(ptr->surface);
  Uint8 *pixel =
    (Uint8*)ptr->surface->pixels + yi * ptr->surface->pitch + xi * 4;
  VALUE color = rb_color_new(
    pixel[0], pixel[1], pixel[2], pixel[3]);
  SDL_UnlockSurface(ptr->surface);
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
  SDL_SetSurfaceBlendMode(fg_rendered, SDL_BLENDMODE_BLEND);
  int fg_width = fg_rendered->w;
  int fg_height = fg_rendered->h;

  // TODO: implement scaling
  rect.x += (rect.w - fg_width) * align / 2;
  if(rect.h > fg_height) rect.y += (rect.h - fg_height) / 2;
  rect.w = fg_width;
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
    SDL_SetSurfaceBlendMode(out_rendered, SDL_BLENDMODE_BLEND);
    int out_width = out_rendered->w;
    int out_height = out_rendered->h;

    SDL_Rect out_rect = rect;
    // out_rect.x -= (out_width - rect.w) / 2;
    // out_rect.y -= (out_height - rect.h) / 2;
    --out_rect.x;
    --out_rect.y;
    out_rect.w = out_width;
    out_rect.h = out_height;

    SDL_BlitSurface(out_rendered, NULL, ptr->surface, &out_rect);
    SDL_FreeSurface(out_rendered);

    TTF_SetFontOutline(sdl_font, 0);
  }
#endif

#if RGSS >= 2
  if(font_ptr->shadow) {
    SDL_Color shadow_color = { 0, 0, 0, 255 };
    SDL_Surface *shadow_rendered =
      TTF_RenderUTF8_Blended(sdl_font, cstr, shadow_color);
    SDL_SetSurfaceBlendMode(shadow_rendered, SDL_BLENDMODE_BLEND);
    SDL_Rect shadow_rect = rect;
    ++shadow_rect.x;
    ++shadow_rect.y;

    SDL_BlitSurface(shadow_rendered, NULL, ptr->surface, &shadow_rect);
    SDL_FreeSurface(shadow_rendered);
  }
#endif

  SDL_BlitSurface(fg_rendered, NULL, ptr->surface, &rect);
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
