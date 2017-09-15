#include <stdbool.h>
#include <SDL.h>
#include <SDL_image.h>
#include <SDL_opengl.h>
#include "Sprite.h"
#include "Bitmap.h"
#include "misc.h"

struct Sprite {
  struct Renderable renderable;
  VALUE bitmap;
};

static bool isSprite(VALUE obj);
static struct Sprite *convertSprite(VALUE obj);
static void rb_sprite_modify(VALUE obj);
static void sprite_mark(struct Sprite *ptr);
static void sprite_free(struct Sprite *ptr);
static VALUE sprite_alloc(VALUE klass);

static VALUE rb_sprite_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_sprite_m_initialize_copy(VALUE self, VALUE orig);

static VALUE rb_sprite_m_bitmap(VALUE self);
static VALUE rb_sprite_m_set_bitmap(VALUE self, VALUE bitmap);

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
  rb_define_method(rb_cSprite, "bitmap", rb_sprite_m_bitmap, 0);
  rb_define_method(rb_cSprite, "bitmap=", rb_sprite_m_set_bitmap, 1);
  // TODO: implement Sprite#dispose
  // TODO: implement Sprite#disposed?
  // TODO: implement Sprite#flash
  // TODO: implement Sprite#update
  // TODO: implement Sprite#width
  // TODO: implement Sprite#height
  // TODO: implement Sprite#src_rect
  // TODO: implement Sprite#src_rect=
  // TODO: implement Sprite#viewport
  // TODO: implement Sprite#viewport=
  // TODO: implement Sprite#visible
  // TODO: implement Sprite#visible=
  // TODO: implement Sprite#x
  // TODO: implement Sprite#x=
  // TODO: implement Sprite#y
  // TODO: implement Sprite#y=
  // TODO: implement Sprite#z
  // TODO: implement Sprite#z=
  // TODO: implement Sprite#ox
  // TODO: implement Sprite#ox=
  // TODO: implement Sprite#oy
  // TODO: implement Sprite#oy=
  // TODO: implement Sprite#zoom_x
  // TODO: implement Sprite#zoom_x=
  // TODO: implement Sprite#zoom_y
  // TODO: implement Sprite#zoom_y=
  // TODO: implement Sprite#angle
  // TODO: implement Sprite#angle=
  // TODO: implement Sprite#wave_amp
  // TODO: implement Sprite#wave_amp=
  // TODO: implement Sprite#wave_length
  // TODO: implement Sprite#wave_length=
  // TODO: implement Sprite#wave_speed
  // TODO: implement Sprite#wave_speed=
  // TODO: implement Sprite#wave_phase
  // TODO: implement Sprite#wave_phase=
  // TODO: implement Sprite#mirror
  // TODO: implement Sprite#mirror=
  // TODO: implement Sprite#bush_depth
  // TODO: implement Sprite#bush_depth=
  // TODO: implement Sprite#bush_opacity
  // TODO: implement Sprite#bush_opacity=
  // TODO: implement Sprite#opacity
  // TODO: implement Sprite#opacity=
  // TODO: implement Sprite#blend_type
  // TODO: implement Sprite#blend_type=
  // TODO: implement Sprite#color
  // TODO: implement Sprite#color=
  // TODO: implement Sprite#tone
  // TODO: implement Sprite#tone=
}

static bool isSprite(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))sprite_mark;
}

static struct Sprite *convertSprite(VALUE obj) {
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

static void rb_sprite_modify(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Sprite");
}

static void sprite_mark(struct Sprite *ptr) {
  (void) ptr;
}

static void sprite_free(struct Sprite *ptr) {
  unregisterRenderable(&ptr->renderable);
  xfree(ptr);
}

static VALUE sprite_alloc(VALUE klass) {
  struct Sprite *ptr = ALLOC(struct Sprite);
  ptr->renderable.render = renderSprite;
  ptr->bitmap = Qnil;
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
  struct Sprite *ptr = convertSprite(self);
  switch(argc) {
    case 0:
      break;
    case 1:
      break;
    default:
      rb_raise(rb_eArgError,
          "wrong number of arguments (%d for 0..1)", argc);
      break;
  }
  return Qnil;
}

static VALUE rb_sprite_m_initialize_copy(VALUE self, VALUE orig) {
  struct Sprite *ptr = convertSprite(self);
  struct Sprite *orig_ptr = convertSprite(orig);
  ptr->bitmap = orig_ptr->bitmap;
  return Qnil;
}

static VALUE rb_sprite_m_bitmap(VALUE self) {
  struct Sprite *ptr = convertSprite(self);
  return ptr->bitmap;
}
static VALUE rb_sprite_m_set_bitmap(VALUE self, VALUE newval) {
  struct Sprite *ptr = convertSprite(self);
  rb_sprite_modify(self);
  if(newval != Qnil) convertBitmap(newval);
  ptr->bitmap = newval;
  return newval;
}

static void renderSprite(struct Renderable *renderable) {
  struct Sprite *ptr = (struct Sprite *)renderable;
  if(ptr->bitmap == Qnil) return;
  struct Bitmap *bitmap_ptr = convertBitmap(ptr->bitmap);

  glClearColor(0.0f, 0.5f, 0.5f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
}
