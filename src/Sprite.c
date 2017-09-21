#include <SDL.h>
#include "gl_misc.h"
#include "Sprite.h"
#include "Bitmap.h"
#include "Viewport.h"
#include "Rect.h"
#include "Color.h"
#include "Tone.h"
#include "misc.h"

static GLuint shader;

static void sprite_mark(struct Sprite *ptr);
static void sprite_free(struct Sprite *ptr);
static VALUE sprite_alloc(VALUE klass);

static VALUE rb_sprite_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_sprite_m_initialize_copy(VALUE self, VALUE orig);

static VALUE rb_sprite_m_dispose(VALUE self);
static VALUE rb_sprite_m_disposed_p(VALUE self);
static VALUE rb_sprite_m_bitmap(VALUE self);
static VALUE rb_sprite_m_set_bitmap(VALUE self, VALUE bitmap);
#if RGSS >= 2
static VALUE rb_sprite_m_width(VALUE self);
static VALUE rb_sprite_m_height(VALUE self);
#endif
static VALUE rb_sprite_m_src_rect(VALUE self);
static VALUE rb_sprite_m_set_src_rect(VALUE self, VALUE newval);
#if RGSS >= 2
static VALUE rb_sprite_m_viewport(VALUE self);
static VALUE rb_sprite_m_set_viewport(VALUE self, VALUE newval);
#endif
static VALUE rb_sprite_m_visible(VALUE self);
static VALUE rb_sprite_m_set_visible(VALUE self, VALUE newval);
static VALUE rb_sprite_m_x(VALUE self);
static VALUE rb_sprite_m_set_x(VALUE self, VALUE newval);
static VALUE rb_sprite_m_y(VALUE self);
static VALUE rb_sprite_m_set_y(VALUE self, VALUE newval);
static VALUE rb_sprite_m_z(VALUE self);
static VALUE rb_sprite_m_set_z(VALUE self, VALUE newval);
static VALUE rb_sprite_m_ox(VALUE self);
static VALUE rb_sprite_m_set_ox(VALUE self, VALUE newval);
static VALUE rb_sprite_m_oy(VALUE self);
static VALUE rb_sprite_m_set_oy(VALUE self, VALUE newval);
static VALUE rb_sprite_m_zoom_x(VALUE self);
static VALUE rb_sprite_m_set_zoom_x(VALUE self, VALUE newval);
static VALUE rb_sprite_m_zoom_y(VALUE self);
static VALUE rb_sprite_m_set_zoom_y(VALUE self, VALUE newval);
static VALUE rb_sprite_m_angle(VALUE self);
static VALUE rb_sprite_m_set_angle(VALUE self, VALUE newval);
#if RGSS >= 2
static VALUE rb_sprite_m_wave_amp(VALUE self);
static VALUE rb_sprite_m_set_wave_amp(VALUE self, VALUE newval);
static VALUE rb_sprite_m_wave_length(VALUE self);
static VALUE rb_sprite_m_set_wave_length(VALUE self, VALUE newval);
static VALUE rb_sprite_m_wave_speed(VALUE self);
static VALUE rb_sprite_m_set_wave_speed(VALUE self, VALUE newval);
static VALUE rb_sprite_m_wave_phase(VALUE self);
static VALUE rb_sprite_m_set_wave_phase(VALUE self, VALUE newval);
#endif
static VALUE rb_sprite_m_mirror(VALUE self);
static VALUE rb_sprite_m_set_mirror(VALUE self, VALUE newval);
static VALUE rb_sprite_m_bush_depth(VALUE self);
static VALUE rb_sprite_m_set_bush_depth(VALUE self, VALUE newval);
#if RGSS >= 2
static VALUE rb_sprite_m_bush_opacity(VALUE self);
static VALUE rb_sprite_m_set_bush_opacity(VALUE self, VALUE newval);
#endif
static VALUE rb_sprite_m_opacity(VALUE self);
static VALUE rb_sprite_m_set_opacity(VALUE self, VALUE newval);
static VALUE rb_sprite_m_blend_type(VALUE self);
static VALUE rb_sprite_m_set_blend_type(VALUE self, VALUE newval);
static VALUE rb_sprite_m_color(VALUE self);
static VALUE rb_sprite_m_set_color(VALUE self, VALUE newval);
static VALUE rb_sprite_m_tone(VALUE self);
static VALUE rb_sprite_m_set_tone(VALUE self, VALUE newval);

static void renderSprite(struct Renderable *renderable);

VALUE rb_cSprite;

/*
 * A graphic object containing a bitmap.
 */
void Init_Sprite(void) {
  rb_cSprite = rb_define_class("Sprite", rb_cObject);
  rb_define_alloc_func(rb_cSprite, sprite_alloc);
  rb_define_private_method(rb_cSprite, "initialize",
      rb_sprite_m_initialize, -1);
  rb_define_private_method(rb_cSprite, "initialize_copy",
      rb_sprite_m_initialize_copy, 1);
  rb_define_method(rb_cSprite, "dispose", rb_sprite_m_dispose, 0);
  rb_define_method(rb_cSprite, "disposed?", rb_sprite_m_disposed_p, 0);
#if RGSS >= 2
  rb_define_method(rb_cSprite, "width", rb_sprite_m_width, 0);
  rb_define_method(rb_cSprite, "height", rb_sprite_m_height, 0);
#endif
  rb_define_method(rb_cSprite, "bitmap", rb_sprite_m_bitmap, 0);
  rb_define_method(rb_cSprite, "bitmap=", rb_sprite_m_set_bitmap, 1);
  rb_define_method(rb_cSprite, "src_rect", rb_sprite_m_src_rect, 0);
  rb_define_method(rb_cSprite, "src_rect=", rb_sprite_m_set_src_rect, 1);
#if RGSS >= 2
  rb_define_method(rb_cSprite, "viewport", rb_sprite_m_viewport, 0);
  rb_define_method(rb_cSprite, "viewport=", rb_sprite_m_set_viewport, 1);
#endif
  rb_define_method(rb_cSprite, "visible", rb_sprite_m_visible, 0);
  rb_define_method(rb_cSprite, "visible=", rb_sprite_m_set_visible, 1);
  rb_define_method(rb_cSprite, "x", rb_sprite_m_x, 0);
  rb_define_method(rb_cSprite, "x=", rb_sprite_m_set_x, 1);
  rb_define_method(rb_cSprite, "y", rb_sprite_m_y, 0);
  rb_define_method(rb_cSprite, "y=", rb_sprite_m_set_y, 1);
  rb_define_method(rb_cSprite, "z", rb_sprite_m_z, 0);
  rb_define_method(rb_cSprite, "z=", rb_sprite_m_set_z, 1);
  rb_define_method(rb_cSprite, "ox", rb_sprite_m_ox, 0);
  rb_define_method(rb_cSprite, "ox=", rb_sprite_m_set_ox, 1);
  rb_define_method(rb_cSprite, "oy", rb_sprite_m_oy, 0);
  rb_define_method(rb_cSprite, "oy=", rb_sprite_m_set_oy, 1);
  rb_define_method(rb_cSprite, "zoom_x", rb_sprite_m_zoom_x, 0);
  rb_define_method(rb_cSprite, "zoom_x=", rb_sprite_m_set_zoom_x, 1);
  rb_define_method(rb_cSprite, "zoom_y", rb_sprite_m_zoom_y, 0);
  rb_define_method(rb_cSprite, "zoom_y=", rb_sprite_m_set_zoom_y, 1);
  rb_define_method(rb_cSprite, "angle", rb_sprite_m_angle, 0);
  rb_define_method(rb_cSprite, "angle=", rb_sprite_m_set_angle, 1);
#if RGSS >= 2
  rb_define_method(rb_cSprite, "wave_amp", rb_sprite_m_wave_amp, 0);
  rb_define_method(rb_cSprite, "wave_amp=", rb_sprite_m_set_wave_amp, 1);
  rb_define_method(rb_cSprite, "wave_length", rb_sprite_m_wave_length, 0);
  rb_define_method(rb_cSprite, "wave_length=", rb_sprite_m_set_wave_length, 1);
  rb_define_method(rb_cSprite, "wave_speed", rb_sprite_m_wave_speed, 0);
  rb_define_method(rb_cSprite, "wave_speed=", rb_sprite_m_set_wave_speed, 1);
  rb_define_method(rb_cSprite, "wave_phase", rb_sprite_m_wave_phase, 0);
  rb_define_method(rb_cSprite, "wave_phase=", rb_sprite_m_set_wave_phase, 1);
#endif
  rb_define_method(rb_cSprite, "mirror", rb_sprite_m_mirror, 0);
  rb_define_method(rb_cSprite, "mirror=", rb_sprite_m_set_mirror, 1);
  rb_define_method(rb_cSprite, "bush_depth", rb_sprite_m_bush_depth, 0);
  rb_define_method(rb_cSprite, "bush_depth=", rb_sprite_m_set_bush_depth, 1);
#if RGSS >= 2
  rb_define_method(rb_cSprite, "bush_opacity", rb_sprite_m_bush_opacity, 0);
  rb_define_method(rb_cSprite, "bush_opacity=",
      rb_sprite_m_set_bush_opacity, 1);
#endif
  rb_define_method(rb_cSprite, "opacity", rb_sprite_m_opacity, 0);
  rb_define_method(rb_cSprite, "opacity=", rb_sprite_m_set_opacity, 1);
  rb_define_method(rb_cSprite, "blend_type", rb_sprite_m_blend_type, 0);
  rb_define_method(rb_cSprite, "blend_type=", rb_sprite_m_set_blend_type, 1);
  rb_define_method(rb_cSprite, "color", rb_sprite_m_color, 0);
  rb_define_method(rb_cSprite, "color=", rb_sprite_m_set_color, 1);
  rb_define_method(rb_cSprite, "tone", rb_sprite_m_tone, 0);
  rb_define_method(rb_cSprite, "tone=", rb_sprite_m_set_tone, 1);
  // TODO: implement Sprite#flash
  // TODO: implement Sprite#update
}

bool rb_sprite_data_p(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))sprite_mark;
}

const struct Sprite *rb_sprite_data(VALUE obj) {
  Check_Type(obj, T_DATA);
  // Note: original RGSS doesn't check types.
  if(RDATA(obj)->dmark != (void(*)(void*))sprite_mark) {
    rb_raise(rb_eTypeError,
        "can't convert %s into Sprite",
        rb_class2name(rb_obj_class(obj)));
  }
  struct Sprite *ret;
  Data_Get_Struct(obj, struct Sprite, ret);
  return ret;
}

struct Sprite *rb_sprite_data_mut(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Sprite");
  return (struct Sprite *)rb_sprite_data(obj);
}

static void sprite_mark(struct Sprite *ptr) {
  rb_gc_mark(ptr->renderable.viewport);
  rb_gc_mark(ptr->bitmap);
  rb_gc_mark(ptr->src_rect);
  rb_gc_mark(ptr->color);
  rb_gc_mark(ptr->tone);
}

static void sprite_free(struct Sprite *ptr) {
  unregisterRenderable(&ptr->renderable);
  xfree(ptr);
}

static VALUE sprite_alloc(VALUE klass) {
  struct Sprite *ptr = ALLOC(struct Sprite);
  ptr->renderable.render = renderSprite;
  ptr->renderable.z = 0;
  ptr->renderable.viewport = Qnil;
  ptr->bitmap = Qnil;
  ptr->disposed = false;
  ptr->src_rect = rb_rect_new2();
  ptr->visible = true;
  ptr->x = 0;
  ptr->y = 0;
  ptr->ox = 0;
  ptr->oy = 0;
  ptr->zoom_x = 1.0;
  ptr->zoom_y = 1.0;
  ptr->angle = 0.0;
#if RGSS >= 2
  ptr->wave_amp = 0;
  ptr->wave_length = 0;
  ptr->wave_speed = 0;
  ptr->wave_phase = 0.0;
#endif
  ptr->mirror = false;
  ptr->bush_depth = 0;
#if RGSS >= 2
  ptr->bush_opacity = 128;
#endif
  ptr->opacity = 255;
  ptr->blend_type = 0;
  ptr->color = rb_color_new2();
  ptr->tone = rb_tone_new2();
  registerRenderable(&ptr->renderable);
  VALUE ret = Data_Wrap_Struct(klass, sprite_mark, sprite_free, ptr);
  return ret;
}

/*
 * call-seq:
 *   Sprite.new
 *   Sprite.new(viewport)
 *
 * Creates new sprite object, possibly with viewport.
 */
static VALUE rb_sprite_m_initialize(int argc, VALUE *argv, VALUE self) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  switch(argc) {
    case 0:
      break;
    case 1:
      if(argv[0] != Qnil) rb_viewport_data(argv[0]);
      ptr->renderable.viewport = argv[0];
      break;
    default:
      rb_raise(rb_eArgError,
          "wrong number of arguments (%d for 0..1)", argc);
      break;
  }
  return Qnil;
}

static VALUE rb_sprite_m_initialize_copy(VALUE self, VALUE orig) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  const struct Sprite *orig_ptr = rb_sprite_data(orig);
  ptr->renderable.z = orig_ptr->renderable.z;
  ptr->renderable.viewport = orig_ptr->renderable.viewport;
  ptr->bitmap = orig_ptr->bitmap;
  rb_rect_set2(ptr->src_rect, orig_ptr->src_rect);
  rb_color_set2(ptr->color, orig_ptr->color);
  rb_tone_set2(ptr->tone, orig_ptr->tone);
  ptr->disposed = orig_ptr->disposed;
  ptr->visible = orig_ptr->visible;
  ptr->mirror = orig_ptr->mirror;
  ptr->x = orig_ptr->x;
  ptr->y = orig_ptr->y;
  ptr->ox = orig_ptr->ox;
  ptr->oy = orig_ptr->oy;
#if RGSS >= 2
  ptr->wave_amp = orig_ptr->wave_amp;
  ptr->wave_length = orig_ptr->wave_length;
  ptr->wave_speed = orig_ptr->wave_speed;
  ptr->bush_opacity = orig_ptr->bush_opacity;
#endif
  ptr->bush_depth = orig_ptr->bush_depth;
  ptr->opacity = orig_ptr->opacity;
  ptr->blend_type = orig_ptr->blend_type;
  ptr->zoom_x = orig_ptr->zoom_x;
  ptr->zoom_y = orig_ptr->zoom_y;
  ptr->angle = orig_ptr->angle;
#if RGSS >= 2
  ptr->wave_phase = orig_ptr->wave_phase;
#endif
  return Qnil;
}

static VALUE rb_sprite_m_dispose(VALUE self) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->disposed = true;
  return Qnil;
}

static VALUE rb_sprite_m_disposed_p(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return ptr->disposed ? Qtrue : Qfalse;
}

static VALUE rb_sprite_m_bitmap(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return ptr->bitmap;
}

static VALUE rb_sprite_m_set_bitmap(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  if(newval != Qnil) rb_bitmap_data(newval);
  ptr->bitmap = newval;
  if(newval != Qnil) rb_rect_set2(ptr->src_rect, rb_bitmap_rect(newval));
  return newval;
}

#if RGSS >= 2
static VALUE rb_sprite_m_width(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(rb_rect_data(ptr->src_rect)->width);
}

static VALUE rb_sprite_m_height(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(rb_rect_data(ptr->src_rect)->height);
}
#endif

static VALUE rb_sprite_m_src_rect(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return ptr->src_rect;
}

static VALUE rb_sprite_m_set_src_rect(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  rb_rect_set2(ptr->src_rect, newval);
  return newval;
}

#if RGSS >= 2
static VALUE rb_sprite_m_viewport(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return ptr->renderable.viewport;
}

static VALUE rb_sprite_m_set_viewport(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  if(newval != Qnil) rb_viewport_data(newval);
  ptr->renderable.viewport = newval;
  return newval;
}
#endif

static VALUE rb_sprite_m_visible(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return ptr->visible ? Qtrue : Qfalse;
}

static VALUE rb_sprite_m_set_visible(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->visible = RTEST(newval);
  return newval;
}

static VALUE rb_sprite_m_x(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->x);
}

static VALUE rb_sprite_m_set_x(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->x = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_y(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->y);
}

static VALUE rb_sprite_m_set_y(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->y = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_z(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->renderable.z);
}

static VALUE rb_sprite_m_set_z(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->renderable.z = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_ox(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->ox);
}

static VALUE rb_sprite_m_set_ox(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->ox = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_oy(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->oy);
}

static VALUE rb_sprite_m_set_oy(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->oy = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_zoom_x(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return DBL2NUM(ptr->zoom_x);
}

static VALUE rb_sprite_m_set_zoom_x(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->zoom_x = NUM2DBL(newval);
  return newval;
}

static VALUE rb_sprite_m_zoom_y(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return DBL2NUM(ptr->zoom_y);
}

static VALUE rb_sprite_m_set_zoom_y(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->zoom_y = NUM2DBL(newval);
  return newval;
}

static VALUE rb_sprite_m_angle(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return DBL2NUM(ptr->angle);
}

static VALUE rb_sprite_m_set_angle(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->angle = NUM2DBL(newval);
  return newval;
}

#if RGSS >= 2
static VALUE rb_sprite_m_wave_amp(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->wave_amp);
}

static VALUE rb_sprite_m_set_wave_amp(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->wave_amp = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_wave_length(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->wave_length);
}

static VALUE rb_sprite_m_set_wave_length(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->wave_length = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_wave_speed(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->wave_speed);
}

static VALUE rb_sprite_m_set_wave_speed(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->wave_speed = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_wave_phase(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return DBL2NUM(ptr->wave_phase);
}

static VALUE rb_sprite_m_set_wave_phase(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->wave_phase = NUM2DBL(newval);
  return newval;
}
#endif

static VALUE rb_sprite_m_mirror(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return ptr->mirror ? Qtrue : Qfalse;
}

static VALUE rb_sprite_m_set_mirror(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->mirror = RTEST(newval);
  return newval;
}

static VALUE rb_sprite_m_bush_depth(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->bush_depth);
}

static VALUE rb_sprite_m_set_bush_depth(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->bush_depth = NUM2INT(newval);
  return newval;
}

#if RGSS >= 2
static VALUE rb_sprite_m_bush_opacity(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->bush_opacity);
}

static VALUE rb_sprite_m_set_bush_opacity(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->bush_opacity = NUM2INT(newval);
  return newval;
}
#endif

static VALUE rb_sprite_m_opacity(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->opacity);
}

static VALUE rb_sprite_m_set_opacity(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  ptr->opacity = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_blend_type(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return INT2NUM(ptr->blend_type);
}

static VALUE rb_sprite_m_set_blend_type(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  /* TODO: check range */
  ptr->blend_type = NUM2INT(newval);
  return newval;
}

static VALUE rb_sprite_m_color(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return ptr->color;
}

static VALUE rb_sprite_m_set_color(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  rb_color_set2(ptr->color, newval);
  return newval;
}
static VALUE rb_sprite_m_tone(VALUE self) {
  const struct Sprite *ptr = rb_sprite_data(self);
  return ptr->tone;
}

static VALUE rb_sprite_m_set_tone(VALUE self, VALUE newval) {
  struct Sprite *ptr = rb_sprite_data_mut(self);
  rb_tone_set2(ptr->tone, newval);
  return newval;
}

static void renderSprite(struct Renderable *renderable) {
  struct Sprite *ptr = (struct Sprite *)renderable;
  if(ptr->renderable.viewport != Qnil) WARN_UNIMPLEMENTED("Sprite#viewport");
  {
    const struct Color *color = rb_color_data(ptr->color);
    if(color->red || color->green || color->blue || color->alpha) {
      WARN_UNIMPLEMENTED("Sprite#color");
    }
  }
  {
    const struct Tone *tone = rb_tone_data(ptr->tone);
    if(tone->red || tone->green || tone->blue || tone->gray) {
      WARN_UNIMPLEMENTED("Sprite#tone");
    }
  }
  if(ptr->mirror) WARN_UNIMPLEMENTED("Sprite#mirror");
#if RGSS >= 2
  if(ptr->wave_amp) WARN_UNIMPLEMENTED("Sprite#wave_amp");
#endif
  if(ptr->bush_depth) WARN_UNIMPLEMENTED("Sprite#bush_depth");
  if(ptr->opacity != 255) WARN_UNIMPLEMENTED("Sprite#opacity");
  if(ptr->blend_type) WARN_UNIMPLEMENTED("Sprite#blend_type");
  if(ptr->angle != 0.0) WARN_UNIMPLEMENTED("Sprite#angle");
  if(ptr->disposed || !ptr->visible) return;
  if(ptr->bitmap == Qnil) return;
  const struct Bitmap *bitmap_ptr = rb_bitmap_data(ptr->bitmap);
  SDL_Surface *surface = bitmap_ptr->surface;
  if(!surface) return;
  const struct Rect *src_rect = rb_rect_data(ptr->src_rect);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glUseProgram(shader);
  glUniform1i(glGetUniformLocation(shader, "tex"), 0);
  glUniform2f(glGetUniformLocation(shader, "dst_size"),
      window_width, window_height);
  glUniform2f(glGetUniformLocation(shader, "src_size"),
      surface->w, surface->h);
  glUniform2f(glGetUniformLocation(shader, "src_topleft"),
      src_rect->x, src_rect->y);
  glUniform2f(glGetUniformLocation(shader, "src_bottomright"),
      src_rect->x + src_rect->width, src_rect->y + src_rect->height);
  glUniform2f(glGetUniformLocation(shader, "dst_translate"),
      ptr->x, ptr->y);
  glUniform2f(glGetUniformLocation(shader, "src_translate"),
      ptr->ox + src_rect->x, ptr->oy + src_rect->y);
  glUniform2f(glGetUniformLocation(shader, "zoom"),
      ptr->zoom_x, ptr->zoom_y);

  glActiveTexture(GL_TEXTURE0);
  bitmapBindTexture((struct Bitmap *)bitmap_ptr);

  gl_draw_rect(-1.0, -1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0);

  glUseProgram(0);
}

void initSpriteSDL() {
  static const char *vsh_source =
    "#version 120\n"
    "\n"
    "void main(void) {\n"
    "    gl_Position = gl_Vertex;\n"
    "}\n";

  static const char *fsh_source =
    "#version 120\n"
    "#if __VERSION__ >= 130\n"
    "#define texture2D texture\n"
    "#define texture2DProj textureProj\n"
    "#endif\n"
    "\n"
    "uniform sampler2D tex;\n"
    "uniform vec2 dst_size;\n"
    "uniform vec2 dst_translate;\n"
    "uniform vec2 src_translate;\n"
    "uniform vec2 src_topleft;\n"
    "uniform vec2 src_bottomright;\n"
    "uniform vec2 src_size;\n"
    "uniform vec2 zoom;\n"
    // "uniform float angle;\n"
    // "uniform vec4 sprite_color;\n"
    // "uniform vec4 sprite_tone;\n"
    "\n"
    "void main(void) {\n"
    "    vec2 coord = vec2(gl_FragCoord.x, dst_size.y - gl_FragCoord.y);\n"
    "    coord = coord - dst_translate;\n"
    "    coord = vec2(coord.x / zoom.x, coord.y / zoom.y);\n"
    "    coord = coord + src_translate;\n"
    "    if(src_topleft.x <= coord.x && src_topleft.y <= coord.y && coord.x <= src_bottomright.x && coord.y <= src_bottomright.y) {\n"
    "      vec4 color = texture2D(tex, vec2(coord.x / src_size.x, coord.y / src_size.y));\n"
    "      gl_FragColor = color;\n"
    "    } else {\n"
    "      gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);\n"
    "    }\n"
    "}\n";

  shader = compileShaders(vsh_source, fsh_source);
}

void deinitSpriteSDL() {
  if(shader) glDeleteProgram(shader);
}
