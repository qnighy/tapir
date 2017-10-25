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

static void font_mark(struct Font *ptr);
static void font_free(struct Font *ptr);
static VALUE font_alloc(VALUE klass);

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
  ptr->size = NUM2INT(rb_cv_get(rb_cFont, "@@default_size"));
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
  int ptsize = ptr->size * 3 / 4;
#else
  int ptsize = ptr->size;
#endif
  ((struct Font *)ptr)->cache = loadFont(
      StringValueCStr(name), ptsize, ptr->bold, ptr->italic);
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
 * Font family and style.
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
  ptr->size = 0;
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
  if(argc > 1) {
    ptr->size = NUM2INT(argv[1]);
  } else {
    ptr->size = NUM2INT(rb_cv_get(rb_cFont, "@@default_size"));
  }
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
  return INT2NUM(ptr->size);
}

static VALUE rb_font_m_set_size(VALUE self, VALUE newval) {
  struct Font *ptr = rb_font_data_mut(self);
  ptr->size = NUM2INT(newval);
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
