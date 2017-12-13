// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "Table.h"
#include "misc.h"
#include "rubyfill.h"

static void table_resize(
    struct Table *ptr, int32_t new_dim, int32_t new_xsize,
    int32_t new_ysize, int32_t new_zsize);

static void table_mark(struct Table *ptr);
static void table_free(struct Table *ptr);
static VALUE table_alloc(VALUE klass);

#define SQRT_UINT32_MAX ((uint32_t)1<<16)

static int32_t multiply_size(
    uint32_t xsize, uint32_t ysize, uint32_t zsize) {
  // Note: original RGSS doesn't check overflow.
  if((xsize >= SQRT_UINT32_MAX || ysize >= SQRT_UINT32_MAX) &&
      xsize > 0 && UINT32_MAX / xsize < ysize) {
    goto fail;
  }
  uint32_t xysize = xsize * ysize;
  if((xysize >= SQRT_UINT32_MAX || zsize >= SQRT_UINT32_MAX) &&
      xysize > 0 && UINT32_MAX / xysize < zsize) {
    goto fail;
  }
  uint32_t size = xysize * zsize;
  if(size > (INT32_MAX - 20) / 2) {
    goto fail;
  }
  return xsize * ysize * zsize;
fail:
  rb_raise(rb_eArgError, "Multiplied table size is too large.");
}

static void table_resize(
    struct Table *ptr, int32_t new_dim, int32_t new_xsize,
    int32_t new_ysize, int32_t new_zsize) {
  if(new_xsize < 0) new_xsize = 0;
  if(new_ysize < 0) new_ysize = 0;
  if(new_zsize < 0) new_zsize = 0;
  int32_t new_size = multiply_size(new_xsize, new_ysize, new_zsize);
  int16_t *new_data = ALLOC_N(int16_t, new_size);
  for(int32_t i = 0; i < new_size; ++i) {
    new_data[i] = 0;
  }
  if(ptr->data) {
    int32_t xsize_min = ptr->xsize < new_xsize ? ptr->xsize : new_xsize;
    int32_t ysize_min = ptr->ysize < new_ysize ? ptr->ysize : new_ysize;
    int32_t zsize_min = ptr->zsize < new_zsize ? ptr->zsize : new_zsize;
    for(int32_t z = 0; z < zsize_min; ++z) {
      for(int32_t y = 0; y < ysize_min; ++y) {
        for(int32_t x = 0; x < xsize_min; ++x) {
          new_data[(z*new_ysize+y)*new_xsize+x] =
            ptr->data[(z*ptr->ysize+y)*ptr->xsize+x];
        }
      }
    }
    xfree(ptr->data);
  }
  ptr->dim = new_dim;
  ptr->xsize = new_xsize;
  ptr->ysize = new_ysize;
  ptr->zsize = new_zsize;
  ptr->size = new_size;
  ptr->data = new_data;
}

static VALUE rb_table_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_table_m_initialize_copy(VALUE self, VALUE orig);

static VALUE rb_table_m_resize(int argc, VALUE *argv, VALUE self);
static VALUE rb_table_m_xsize(VALUE self);
static VALUE rb_table_m_ysize(VALUE self);
static VALUE rb_table_m_zsize(VALUE self);
static VALUE rb_table_m_aref(int argc, VALUE *argv, VALUE self);
static VALUE rb_table_m_aset(int argc, VALUE *argv, VALUE self);
static VALUE rb_table_s_old_load(VALUE self, VALUE s);
static VALUE rb_table_m_old_dump(VALUE self, VALUE lim);

VALUE rb_cTable;

/*
 * A table is 1, 2, or 3-dimensional array of <tt>int16_t</tt> values.
 *
 * == Bugs
 *
 * - Table.new doesn't check multiplication overflow. Therefore a code like
 *   <tt>Table.new(65536, 65536)</tt> will generate an ill-formed table.
 */
void Init_Table() {
  rb_cTable = rb_define_class("Table", rb_cObject);
  rb_define_alloc_func(rb_cTable, table_alloc);
  rb_define_private_method(rb_cTable, "initialize", rb_table_m_initialize, -1);
  rb_define_private_method(rb_cTable, "initialize_copy",
      rb_table_m_initialize_copy, 1);
  rb_define_method(rb_cTable, "resize", rb_table_m_resize, -1);
  rb_define_method(rb_cTable, "xsize", rb_table_m_xsize, 0);
  rb_define_method(rb_cTable, "ysize", rb_table_m_ysize, 0);
  rb_define_method(rb_cTable, "zsize", rb_table_m_zsize, 0);
  rb_define_method(rb_cTable, "[]", rb_table_m_aref, -1);
  rb_define_method(rb_cTable, "[]=", rb_table_m_aset, -1);

  rb_define_singleton_method(rb_cTable, "_load", rb_table_s_old_load, 1);
  rb_define_method(rb_cTable, "_dump", rb_table_m_old_dump, 1);
}

bool rb_table_data_p(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))table_mark;
}

const struct Table *rb_table_data(VALUE obj) {
  Check_Type(obj, T_DATA);
  // Note: original RGSS doesn't check types.
  if(RDATA(obj)->dmark != (void(*)(void*))table_mark) {
    rb_raise(rb_eTypeError,
        "can't convert %s into Table",
        rb_class2name(rb_obj_class(obj)));
  }
  struct Table *ret;
  Data_Get_Struct(obj, struct Table, ret);
  return ret;
}

struct Table *rb_table_data_mut(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Table");
  return (struct Table *)rb_table_data(obj);
}

static void table_mark(struct Table *ptr) {
  (void) ptr;
}
static void table_free(struct Table *ptr) {
  if(ptr->data) xfree(ptr->data);
  xfree(ptr);
}

static VALUE table_alloc(VALUE klass) {
  struct Table *ptr = ALLOC(struct Table);
  ptr->dim = 0;
  ptr->xsize = 0;
  ptr->ysize = 0;
  ptr->zsize = 0;
  ptr->size = 0;
  ptr->data = NULL;
  VALUE ret = Data_Wrap_Struct(klass, table_mark, table_free, ptr);
  return ret;
}

/*
 * call-seq:
 *   Table.new(xsize) -> table
 *   Table.new(xsize, ysize) -> table
 *   Table.new(xsize, ysize, zsize) -> table
 *
 * Creates a new table of 1, 2, or 3 dimension.
 *
 * <code>xsize</code>, <code>ysize</code>, and <code>zsize</code> are
 * interpreted as <tt>int32_t</tt> values.
 * Negative values are adjusted to zero.
 */
static VALUE rb_table_m_initialize(int argc, VALUE *argv, VALUE self) {
  struct Table *ptr = rb_table_data_mut(self);
  if(ptr->data) {
    xfree(ptr->data);
    ptr->data = NULL;
  }
  if(1 <= argc && argc <= 3) {
    table_resize(
        ptr, argc,
        0 < argc ? NUM2INT(argv[0]) : 1,
        1 < argc ? NUM2INT(argv[1]) : 1,
        2 < argc ? NUM2INT(argv[2]) : 1);
  } else {
    // Note: original RGSS has wrong messages.
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 1..3)", argc);
  }
  return Qnil;
}
static VALUE rb_table_m_initialize_copy(VALUE self, VALUE orig) {
  struct Table *ptr = rb_table_data_mut(self);
  const struct Table *orig_ptr = rb_table_data(orig);
  ptr->dim = orig_ptr->dim;
  ptr->xsize = orig_ptr->xsize;
  ptr->ysize = orig_ptr->ysize;
  ptr->zsize = orig_ptr->zsize;
  ptr->size = orig_ptr->size;
  ptr->data = ALLOC_N(int16_t, ptr->size);
  for(int32_t i = 0; i < ptr->size; ++i) {
    ptr->data[i] = orig_ptr->data[i];
  }
  return Qnil;
}

/*
 * call-seq:
 *   resize(xsize) -> table
 *   resize(xsize, ysize) -> table
 *   resize(xsize, ysize, zsize) -> table
 *
 * Resizes the table to a specified size.
 *
 * <code>xsize</code>, <code>ysize</code>, and <code>zsize</code> are
 * interpreted as <tt>int32_t</tt> values.
 * Negative values are adjusted to zero.
 *
 * It preserves existing elements. When expanding, new areas are filled by 0.
 *
 * It can also change the dimension of the table.
 * In this case, <code>y</code> and <code>z</code> defaults to 0
 * if necessary.
 *
 * It returns the table itself.
 */
static VALUE rb_table_m_resize(int argc, VALUE *argv, VALUE self) {
  struct Table *ptr = rb_table_data_mut(self);
  if(1 <= argc && argc <= 3) {
    table_resize(
        ptr, argc,
        0 < argc ? NUM2INT(argv[0]) : 1,
        1 < argc ? NUM2INT(argv[1]) : 1,
        2 < argc ? NUM2INT(argv[2]) : 1);
  } else {
    // Note: original RGSS has wrong messages.
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 1..3)", argc);
  }
  return self;
}

/*
 * call-seq:
 *    table.xsize -> integer
 *
 * Returns the first component of the size.
 */
static VALUE rb_table_m_xsize(VALUE self) {
  const struct Table *ptr = rb_table_data(self);
  return INT2NUM(ptr->xsize);
}

/*
 * call-seq:
 *    table.ysize -> integer
 *
 * Returns the second component of the size.
 * If the dimension is 1, it returns 1.
 */
static VALUE rb_table_m_ysize(VALUE self) {
  const struct Table *ptr = rb_table_data(self);
  return INT2NUM(ptr->ysize);
}

/*
 * call-seq:
 *    table.zsize -> integer
 *
 * Returns the third component of the size.
 * If the dimension is 1 or 2, it returns 1.
 */
static VALUE rb_table_m_zsize(VALUE self) {
  const struct Table *ptr = rb_table_data(self);
  return INT2NUM(ptr->zsize);
}

/*
 * call-seq:
 *    table[x] -> integer
 *    table[x, y] -> integer
 *    table[x, y, z] -> integer
 *
 * Returns an element of the table.
 * <code>x</code>, <code>y</code> and <code>z</code> are
 * interpreted as <tt>int32_t</tt> values.
 *
 * The number of the arguments must match the dimension of the table.
 *
 * If the index is out of bounds, <code>nil</code> is returned.
 */
static VALUE rb_table_m_aref(int argc, VALUE *argv, VALUE self) {
  const struct Table *ptr = rb_table_data(self);
  if(argc == ptr->dim) {
    int32_t x = 0 < argc ? NUM2INT(argv[0]) : 0;
    int32_t y = 1 < argc ? NUM2INT(argv[1]) : 0;
    int32_t z = 2 < argc ? NUM2INT(argv[2]) : 0;
    if(0 <= x && x < ptr->xsize && 0 <= y && y < ptr->ysize &&
        0 <= z && z < ptr->zsize) {
      return INT2NUM(ptr->data[((z * ptr->ysize) + y) * ptr->xsize + x]);
    } else {
      return Qnil;
    }
  } else {
    // Note: original RGSS has wrong messages.
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for %d)", argc, ptr->dim);
  }
  return Qnil;
}

/*
 * call-seq:
 *    table[] = newval -> newval
 *    table[x] = newval -> newval
 *    table[x, y] = newval -> newval
 *    table[x, y, z] = newval -> newval
 *
 * Modifies an element of the table.
 * <code>x</code>, <code>y</code> and <code>z</code> are
 * interpreted as <tt>int32_t</tt> values.
 *
 * <code>newval</code> is first interpreted as an <tt>int32_t</tt> value,
 * and then casted to <tt>int16_t</tt> value by wrapping.
 *
 * Usually, the number of the arguments must be exactly one more than
 * the dimension of the table.
 * However, there is an RGSS bug that this method also accepts one
 * less arguments. In this case, the last index is assumed to be 0.
 *
 * If the index is out of bounds, it does nothing.
 */
static VALUE rb_table_m_aset(int argc, VALUE *argv, VALUE self) {
  struct Table *ptr = rb_table_data_mut(self);
  // Note: original RGSS wrongly accepts one less arguments.
  if(argc == ptr->dim || argc == ptr->dim+1) {
    int32_t x = 0 < argc-1 ? NUM2INT(argv[0]) : 0;
    int32_t y = 1 < argc-1 ? NUM2INT(argv[1]) : 0;
    int32_t z = 2 < argc-1 ? NUM2INT(argv[2]) : 0;
    int16_t val = (uint16_t)NUM2INT(argv[argc-1]);
    if(0 <= x && x < ptr->xsize && 0 <= y && y < ptr->ysize &&
        0 <= z && z < ptr->zsize) {
      ptr->data[((z * ptr->ysize) + y) * ptr->xsize + x] = val;
      return INT2NUM(val);
    } else {
      return Qnil;
    }
  } else {
    // Note: original RGSS has wrong messages.
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for %d)", argc, ptr->dim+1);
  }
  return Qnil;
}

/*
 * call-seq:
 *   Table._load(str) -> table
 *
 * Loads a table from <code>str</code>. Used in <code>Marshal.load</code>.
 *
 * See Table#_dump for the format.
 */
static VALUE rb_table_s_old_load(VALUE klass, VALUE str) {
  (void) klass;
  VALUE ret = table_alloc(rb_cTable);
  struct Table *ptr = rb_table_data_mut(ret);
  StringValue(str);
  // Note: original RGSS doesn't check types.
  Check_Type(str, T_STRING);
  const char *s = RSTRING_PTR(str);
  // Note: original RGSS doesn't check length.
  long s_len = RSTRING_LEN(str);
  if(s_len < (long)(sizeof(int32_t)*5)) {
    rb_raise(rb_eArgError, "Corrupted marshal data for Table.");
  }
  if(!s) s = "";
  ptr->dim = read_int32(s+sizeof(int32_t)*0);
  ptr->xsize = read_int32(s+sizeof(int32_t)*1);
  ptr->ysize = read_int32(s+sizeof(int32_t)*2);
  ptr->zsize = read_int32(s+sizeof(int32_t)*3);
  ptr->size = read_int32(s+sizeof(int32_t)*4);
  // Note: original RGSS doesn't check dimension or size.
  if(ptr->dim < 1 || ptr->dim > 3 ||
      ptr->xsize < 0 || ptr->ysize < 0 || ptr->zsize < 0) {
    rb_raise(rb_eArgError, "Corrupted marshal data for Table.");
  }
  // Note: original RGSS doesn't check total size.
  if(ptr->size != multiply_size(ptr->xsize, ptr->ysize, ptr->zsize)) {
    rb_raise(rb_eArgError, "Corrupted marshal data for Table.");
  }
  // Note: original RGSS doesn't check length.
  if(s_len - sizeof(int32_t)*5 != sizeof(int16_t)*ptr->size) {
    rb_raise(rb_eArgError, "Corrupted marshal data for Table.");
  }
  if(ptr->data) xfree(ptr->data);
  ptr->data = ALLOC_N(int16_t, ptr->size);
  for(int32_t i = 0; i < ptr->size; ++i) {
    ptr->data[i] = read_int16(s+sizeof(int32_t)*5+sizeof(int16_t)*i);
  }
  return ret;
}

/*
 * call-seq:
 *   table._dump(limit) -> string
 *
 * Dumps a table to a string. Used in <code>Marshal.dump</code>.
 *
 * Same as <code>[xsize, ysize, zsize, size, *contents].pack("l<l<l<l<s*<")</code>, where
 *
 * - <code>size = xsize * ysize * zsize</code>
 * - <code>contents[x + xsize * (y + ysize * z)] = table[x, y, z]</code> (if dimension is 3)
 * - <code>contents[x + xsize * y] = table[x, y]</code> (if dimension is 2)
 * - <code>contents[x] = table[x]</code> (if dimension is 1)
 */
static VALUE rb_table_m_old_dump(VALUE self, VALUE limit) {
  (void) limit;
  const struct Table *ptr = rb_table_data(self);
  size_t dumpsize = sizeof(int32_t)*5+sizeof(int16_t)*(ptr->size);
  char *s = (char *)xmalloc(dumpsize);
  write_int32(s, ptr->dim);
  write_int32(s+4, ptr->xsize);
  write_int32(s+8, ptr->ysize);
  write_int32(s+12, ptr->zsize);
  write_int32(s+16, ptr->size);
  for(int32_t i = 0; i < ptr->size; ++i) {
    write_int16(s+20+i*2, ptr->data[i]);
  }
  VALUE ret = rb_str_new(s, dumpsize);
  xfree(s);
  return ret;
}
