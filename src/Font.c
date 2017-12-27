// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "Font.h"
#include "Color.h"
#include "font_lookup.h"
#include "openres.h"
#include "misc.h"
#include "rubyfill.h"

static void font_mark(struct Font *ptr);
static void font_free(struct Font *ptr);
static VALUE font_alloc(VALUE klass);

static double as_double(VALUE val) {
  if(TYPE(val) == T_FLOAT) {
    return NUM2DBL(val);
  } else {
    return NUM2INT(val);
  }
}

static void font_invalidate_cache(struct Font *ptr) {
  if(ptr->cache) {
    TTF_CloseFont(ptr->cache);
    ptr->cache = NULL;
  }
}

VALUE rb_font_new(void) {
  VALUE ret = font_alloc(rb_cFont);
  struct Font *ptr = rb_font_data_mut(ret);
  ptr->name = rb_cv_get(rb_cFont, "@@default_name");
  rb_funcall(ret, rb_intern("size="), 1, rb_cv_get(rb_cFont, "@@default_size"));
  ptr->bold = RTEST(rb_cv_get(rb_cFont, "@@default_bold"));
  ptr->italic = RTEST(rb_cv_get(rb_cFont, "@@default_italic"));
#if RGSS == 3
  ptr->outline = RTEST(rb_cv_get(rb_cFont, "@@default_outline"));
#endif
#if RGSS >= 2
  ptr->shadow = RTEST(rb_cv_get(rb_cFont, "@@default_shadow"));
#endif
  rb_color_set2(ptr->color, rb_cv_get(rb_cFont, "@@default_color"));
#if RGSS == 3
  rb_color_set2(ptr->out_color, rb_cv_get(rb_cFont, "@@default_out_color"));
#endif
  return ret;
}

void rb_font_set(VALUE self, VALUE other) {
  struct Font *ptr = rb_font_data_mut(self);
  const struct Font *orig_ptr = rb_font_data(other);
  ptr->name = orig_ptr->name;
  ptr->size = orig_ptr->size;
  ptr->bold = orig_ptr->bold;
  ptr->italic = orig_ptr->italic;
#if RGSS == 3
  ptr->outline = orig_ptr->outline;
#endif
#if RGSS >= 2
  ptr->shadow = orig_ptr->shadow;
#endif
  rb_color_set2(ptr->color, orig_ptr->color);
#if RGSS == 3
  rb_color_set2(ptr->out_color, orig_ptr->out_color);
#endif
}

TTF_Font *rb_font_to_sdl(VALUE self) {
  const struct Font *ptr = rb_font_data(self);
  if(ptr->cache) return ptr->cache;
  VALUE name;
  if(TYPE(ptr->name) == T_ARRAY) {
    // TODO: multiple font names
    name = rb_ary_entry(ptr->name, 0);
  } else {
    name = ptr->name;
  }
#if RGSS == 3
  // Note: Font#size seems to be px under 96dpi. multiplying 3/4 to convert to pt.
  double ptsize = as_double(ptr->size) * 0.75;
#else
  double ptsize = as_double(ptr->size);
#endif
  if(!(6.0 <= ptsize && ptsize < 97.0)) {
    rb_raise(rb_eRuntimeError, "Invalid Font#size");
  }
  ((struct Font *)ptr)->cache = loadFont(
      StringValueCStr(name), (int)ptsize, ptr->bold, ptr->italic);
  return ptr->cache;
}

static VALUE rb_font_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_font_m_initialize_copy(VALUE self, VALUE orig);
static VALUE rb_font_s_exist_p(VALUE klass, VALUE name);
static VALUE rb_font_m_name(VALUE self);
static VALUE rb_font_m_set_name(VALUE self, VALUE newval);
static VALUE rb_font_m_size(VALUE self);
static VALUE rb_font_m_set_size(VALUE self, VALUE newval);
static VALUE rb_font_m_bold(VALUE self);
static VALUE rb_font_m_set_bold(VALUE self, VALUE newval);
static VALUE rb_font_m_italic(VALUE self);
static VALUE rb_font_m_set_italic(VALUE self, VALUE newval);
#if RGSS == 3
static VALUE rb_font_m_outline(VALUE self);
static VALUE rb_font_m_set_outline(VALUE self, VALUE newval);
#endif
#if RGSS >= 2
static VALUE rb_font_m_shadow(VALUE self);
static VALUE rb_font_m_set_shadow(VALUE self, VALUE newval);
#endif
static VALUE rb_font_m_color(VALUE self);
static VALUE rb_font_m_set_color(VALUE self, VALUE newval);
#if RGSS == 3
static VALUE rb_font_m_out_color(VALUE self);
static VALUE rb_font_m_set_out_color(VALUE self, VALUE newval);
#endif

VALUE rb_cFont;

/*
 * A font consists of the following data:
 *
 * - Its *name*, a mere Ruby value (expected to be a String or an array of String)
 * - Its *size*, a mere Ruby value (expected to be an Integer or a Float)
 * - Whether it's *bold* or not, a boolean value
 * - Whether it's *italic* or not, a boolean value
 * - Its *color*, a Color value
 * - Whether the *shadow* is rendered or not, a boolean value (RGSS2 or RGSS3 only)
 * - Whether the *outline* is rendered or not, a boolean value (RGSS3 only)
 * - Its <b>outline color</b>, a Color value (RGSS3 only)
 *
 * == Bugs
 *
 * - Font#size= can accept an object which is neither Integer or Float, if it implements <tt>to_int</tt>.
 */
void Init_Font(void) {
  rb_cFont = rb_define_class("Font", rb_cObject);
  rb_define_alloc_func(rb_cFont, font_alloc);
  rb_define_private_method(rb_cFont, "initialize",
      rb_font_m_initialize, -1);
  rb_define_private_method(rb_cFont, "initialize_copy",
      rb_font_m_initialize_copy, 1);
  rb_define_singleton_method(rb_cFont, "exist?", rb_font_s_exist_p, 1);
  rb_define_method(rb_cFont, "name", rb_font_m_name, 0);
  rb_define_method(rb_cFont, "name=", rb_font_m_set_name, 1);
  rb_define_method(rb_cFont, "size", rb_font_m_size, 0);
  rb_define_method(rb_cFont, "size=", rb_font_m_set_size, 1);
  rb_define_method(rb_cFont, "bold", rb_font_m_bold, 0);
  rb_define_method(rb_cFont, "bold=", rb_font_m_set_bold, 1);
  rb_define_method(rb_cFont, "italic", rb_font_m_italic, 0);
  rb_define_method(rb_cFont, "italic=", rb_font_m_set_italic, 1);
#if RGSS == 3
  rb_define_method(rb_cFont, "outline", rb_font_m_outline, 0);
  rb_define_method(rb_cFont, "outline=", rb_font_m_set_outline, 1);
#endif
#if RGSS >= 2
  rb_define_method(rb_cFont, "shadow", rb_font_m_shadow, 0);
  rb_define_method(rb_cFont, "shadow=", rb_font_m_set_shadow, 1);
#endif
  rb_define_method(rb_cFont, "color", rb_font_m_color, 0);
  rb_define_method(rb_cFont, "color=", rb_font_m_set_color, 1);
#if RGSS == 3
  rb_define_method(rb_cFont, "out_color", rb_font_m_out_color, 0);
  rb_define_method(rb_cFont, "out_color=", rb_font_m_set_out_color, 1);
#endif
}

bool rb_font_data_p(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))font_mark;
}

const struct Font *rb_font_data(VALUE obj) {
  Check_Type(obj, T_DATA);
  // Note: original RGSS doesn't check types.
  if(RDATA(obj)->dmark != (void(*)(void*))font_mark) {
    rb_raise(rb_eTypeError,
        "can't convert %s into Font",
        rb_class2name(rb_obj_class(obj)));
  }
  struct Font *ret;
  Data_Get_Struct(obj, struct Font, ret);
  return ret;
}

struct Font *rb_font_data_mut(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Font");
  return (struct Font *)rb_font_data(obj);
}

static void font_mark(struct Font *ptr) {
  rb_gc_mark(ptr->name);
  rb_gc_mark(ptr->size);
  rb_gc_mark(ptr->color);
#if RGSS == 3
  rb_gc_mark(ptr->out_color);
#endif
}

static void font_free(struct Font *ptr) {
  font_invalidate_cache(ptr);
  xfree(ptr);
}

static VALUE font_alloc(VALUE klass) {
  struct Font *ptr = ALLOC(struct Font);
  ptr->name = Qnil;
  ptr->size = Qnil;
  ptr->bold = false;
  ptr->italic = false;
#if RGSS == 3
  ptr->outline = false;
#endif
#if RGSS >= 2
  ptr->shadow = false;
#endif
  ptr->color = Qnil;
#if RGSS == 3
  ptr->out_color = Qnil;
#endif
  ptr->cache = NULL;
  VALUE ret = Data_Wrap_Struct(klass, font_mark, font_free, ptr);
  ptr->color = rb_color_new2();
#if RGSS == 3
  ptr->out_color = rb_color_new2();
#endif
  return ret;
}

/*
 * call-seq:
 *   Font.new
 *   Font.new(name)
 *   Font.new(name, size)
 *
 * Creates a new font with optional name and size.
 *
 * It actually does the following things:
 *
 * - Calls Font#name= with Font.default_name or the first argument.
 * - Calls Font#size= with Font.default_size or the second argument.
 * - Calls Font#bold= with Font.default_bold.
 * - Calls Font#italic= with Font.default_italic.
 * - Copies Font.default_color's content to Font#color.
 * - Calls Font#shadow= with Font.default_shadow. (RGSS2 and RGSS3 only)
 * - Calls Font#outline= with Font.default_outline. (RGSS3 only)
 * - Copies Font.default_out_color's content to Font#out_color. (RGSS3 only)
 */
static VALUE rb_font_m_initialize(int argc, VALUE *argv, VALUE self) {
  struct Font *ptr = rb_font_data_mut(self);
  if(argc > 2) {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 0..2)", argc);
  }
  if(argc > 0) {
    ptr->name = argv[0];
  } else {
    ptr->name = rb_cv_get(rb_cFont, "@@default_name");
  }
  VALUE newsize;
  if(argc > 1) {
    newsize = argv[1];
  } else {
    newsize = rb_cv_get(rb_cFont, "@@default_size");
  }
  rb_funcall(self, rb_intern("size="), 1, newsize);
  ptr->bold = RTEST(rb_cv_get(rb_cFont, "@@default_bold"));
  ptr->italic = RTEST(rb_cv_get(rb_cFont, "@@default_italic"));
#if RGSS == 3
  ptr->outline = RTEST(rb_cv_get(rb_cFont, "@@default_outline"));
#endif
#if RGSS >= 2
  ptr->shadow = RTEST(rb_cv_get(rb_cFont, "@@default_shadow"));
#endif
  rb_color_set2(ptr->color, rb_cv_get(rb_cFont, "@@default_color"));
#if RGSS == 3
  rb_color_set2(ptr->out_color, rb_cv_get(rb_cFont, "@@default_out_color"));
#endif
  return Qnil;
}

static VALUE rb_font_m_initialize_copy(VALUE self, VALUE orig) {
  struct Font *ptr = rb_font_data_mut(self);
  const struct Font *orig_ptr = rb_font_data(orig);
  ptr->name = orig_ptr->name;
  ptr->size = orig_ptr->size;
  ptr->bold = orig_ptr->bold;
  ptr->italic = orig_ptr->italic;
#if RGSS == 3
  ptr->outline = orig_ptr->outline;
#endif
#if RGSS >= 2
  ptr->shadow = orig_ptr->shadow;
#endif
  rb_color_set2(ptr->color, orig_ptr->color);
#if RGSS == 3
  rb_color_set2(ptr->out_color, orig_ptr->out_color);
#endif
  font_invalidate_cache(ptr);
  return Qnil;
}

static VALUE rb_font_s_exist_p(VALUE klass, VALUE name) {
  (void) klass;

  return fontExistence(StringValueCStr(name)) ? Qtrue : Qfalse;
}

static VALUE rb_font_m_name(VALUE self) {
  const struct Font *ptr = rb_font_data(self);
  return ptr->name;
}

static VALUE rb_font_m_set_name(VALUE self, VALUE newval) {
  struct Font *ptr = rb_font_data_mut(self);
  ptr->name = newval;
  font_invalidate_cache(ptr);
  return newval;
}

static VALUE rb_font_m_size(VALUE self) {
  const struct Font *ptr = rb_font_data(self);
  return ptr->size;
}


/*
 * call-seq:
 *   font.size = newval -> newval
 *
 * Modifies the size of the font.
 * _newval_ is expected to be an integer or a Float.
 *
 * ArgumentError is raised if the new value is out of
 * <code>(6.0...97.0)</code> range.
 */
static VALUE rb_font_m_set_size(VALUE self, VALUE newval) {
  struct Font *ptr = rb_font_data_mut(self);
  double size = as_double(newval);
  // Note: this misses NaN
  if(size < 6.0 || 97.0 <= size) {
    rb_raise(rb_eArgError, "bad value for size");
  }
  ptr->size = newval;
  font_invalidate_cache(ptr);
  return newval;
}

static VALUE rb_font_m_bold(VALUE self) {
  const struct Font *ptr = rb_font_data(self);
  return ptr->bold ? Qtrue : Qfalse;
}

static VALUE rb_font_m_set_bold(VALUE self, VALUE newval) {
  struct Font *ptr = rb_font_data_mut(self);
  ptr->bold = RTEST(newval);
  font_invalidate_cache(ptr);
  return newval;
}

static VALUE rb_font_m_italic(VALUE self) {
  const struct Font *ptr = rb_font_data(self);
  return ptr->italic ? Qtrue : Qfalse;
}

static VALUE rb_font_m_set_italic(VALUE self, VALUE newval) {
  struct Font *ptr = rb_font_data_mut(self);
  ptr->italic = RTEST(newval);
  font_invalidate_cache(ptr);
  return newval;
}

#if RGSS == 3
static VALUE rb_font_m_outline(VALUE self) {
  const struct Font *ptr = rb_font_data(self);
  return ptr->outline ? Qtrue : Qfalse;
}

static VALUE rb_font_m_set_outline(VALUE self, VALUE newval) {
  struct Font *ptr = rb_font_data_mut(self);
  ptr->outline = RTEST(newval);
  font_invalidate_cache(ptr);
  return newval;
}
#endif

#if RGSS >= 2
static VALUE rb_font_m_shadow(VALUE self) {
  const struct Font *ptr = rb_font_data(self);
  return ptr->shadow ? Qtrue : Qfalse;
}

static VALUE rb_font_m_set_shadow(VALUE self, VALUE newval) {
  struct Font *ptr = rb_font_data_mut(self);
  ptr->shadow = RTEST(newval);
  font_invalidate_cache(ptr);
  return newval;
}
#endif

static VALUE rb_font_m_color(VALUE self) {
  const struct Font *ptr = rb_font_data(self);
  return ptr->color;
}

static VALUE rb_font_m_set_color(VALUE self, VALUE newval) {
  struct Font *ptr = rb_font_data_mut(self);
  rb_color_set2(ptr->color, newval);
  font_invalidate_cache(ptr);
  return newval;
}

#if RGSS == 3
static VALUE rb_font_m_out_color(VALUE self) {
  const struct Font *ptr = rb_font_data(self);
  return ptr->out_color;
}

static VALUE rb_font_m_set_out_color(VALUE self, VALUE newval) {
  struct Font *ptr = rb_font_data_mut(self);
  rb_color_set2(ptr->out_color, newval);
  font_invalidate_cache(ptr);
  return newval;
}
#endif
