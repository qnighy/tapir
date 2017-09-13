#include <stdbool.h>
#include "Bitmap.h"
#include "misc.h"

struct Bitmap {
  int foo;
};

static bool isBitmap(VALUE obj);
static struct Bitmap *convertBitmap(VALUE obj);
static void rb_bitmap_modify(VALUE obj);
static void bitmap_mark(struct Bitmap *ptr);
static VALUE bitmap_alloc(VALUE klass);

VALUE rb_cBitmap;

/*
 * RGBA bitmap buffer.
 */
void Init_Bitmap(void) {
  rb_cBitmap = rb_define_class("Bitmap", rb_cObject);
  rb_define_alloc_func(rb_cBitmap, bitmap_alloc);
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

static void rb_bitmap_modify(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Bitmap");
}

static void bitmap_mark(struct Bitmap *ptr) {
  (void) ptr;
}

static VALUE bitmap_alloc(VALUE klass) {
  struct Bitmap *ptr = ALLOC(struct Bitmap);
  ptr->foo = 0;
  VALUE ret = Data_Wrap_Struct(klass, bitmap_mark, -1, ptr);
  return ret;
}
