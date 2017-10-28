// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "Tilemap.h"
#include <SDL.h>
#include "gl_misc.h"
#include "BitmapArray.h"
#include "Bitmap.h"
#include "Viewport.h"
#include "Table.h"
#include "misc.h"

static GLuint shader;

static void tilemap_mark(struct Tilemap *ptr);
static void tilemap_free(struct Tilemap *ptr);
static VALUE tilemap_alloc(VALUE klass);

static VALUE rb_tilemap_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_tilemap_m_initialize_copy(VALUE self, VALUE orig);

static VALUE rb_tilemap_m_dispose(VALUE self);
static VALUE rb_tilemap_m_disposed_p(VALUE self);
static VALUE rb_tilemap_m_update(VALUE self);
#if RGSS >= 2
static VALUE rb_tilemap_m_bitmaps(VALUE self);
#else
static VALUE rb_tilemap_m_tileset(VALUE self);
static VALUE rb_tilemap_m_set_tileset(VALUE self, VALUE newval);
static VALUE rb_tilemap_m_autotiles(VALUE self);
#endif
static VALUE rb_tilemap_m_map_data(VALUE self);
static VALUE rb_tilemap_m_set_map_data(VALUE self, VALUE newval);
static VALUE rb_tilemap_m_flash_data(VALUE self);
static VALUE rb_tilemap_m_set_flash_data(VALUE self, VALUE newval);
#if RGSS >= 2
static VALUE rb_tilemap_m_flags(VALUE self);
static VALUE rb_tilemap_m_set_flags(VALUE self, VALUE newval);
#else
static VALUE rb_tilemap_m_priorities(VALUE self);
static VALUE rb_tilemap_m_set_priorities(VALUE self, VALUE newval);
#endif
static VALUE rb_tilemap_m_viewport(VALUE self);
#if RGSS >= 2
static VALUE rb_tilemap_m_set_viewport(VALUE self, VALUE newval);
#endif
static VALUE rb_tilemap_m_visible(VALUE self);
static VALUE rb_tilemap_m_set_visible(VALUE self, VALUE newval);
static VALUE rb_tilemap_m_ox(VALUE self);
static VALUE rb_tilemap_m_set_ox(VALUE self, VALUE newval);
static VALUE rb_tilemap_m_oy(VALUE self);
static VALUE rb_tilemap_m_set_oy(VALUE self, VALUE newval);

static void prepareRenderTilemap(struct Renderable *renderable, int t);
static void renderTilemap(
    struct Renderable *renderable, const struct RenderJob *job,
    const struct RenderViewport *viewport);

static void renderTile(struct Tilemap *ptr, int tile_id, int x, int y,
    const struct RenderViewport *viewport);

VALUE rb_cTilemap;

void Init_Tilemap(void) {
  rb_cTilemap = rb_define_class("Tilemap", rb_cObject);
  rb_define_alloc_func(rb_cTilemap, tilemap_alloc);
  rb_define_private_method(rb_cTilemap, "initialize",
      rb_tilemap_m_initialize, -1);
  rb_define_private_method(rb_cTilemap, "initialize_copy",
      rb_tilemap_m_initialize_copy, 1);
  rb_define_method(rb_cTilemap, "dispose", rb_tilemap_m_dispose, 0);
  rb_define_method(rb_cTilemap, "disposed?", rb_tilemap_m_disposed_p, 0);
  rb_define_method(rb_cTilemap, "update", rb_tilemap_m_update, 0);
#if RGSS >= 2
  rb_define_method(rb_cTilemap, "bitmaps", rb_tilemap_m_bitmaps, 0);
#else
  rb_define_method(rb_cTilemap, "tileset", rb_tilemap_m_tileset, 0);
  rb_define_method(rb_cTilemap, "tileset=", rb_tilemap_m_set_tileset, 1);
  rb_define_method(rb_cTilemap, "autotiles", rb_tilemap_m_autotiles, 0);
#endif
  rb_define_method(rb_cTilemap, "map_data", rb_tilemap_m_map_data, 0);
  rb_define_method(rb_cTilemap, "map_data=", rb_tilemap_m_set_map_data, 1);
  rb_define_method(rb_cTilemap, "flash_data", rb_tilemap_m_flash_data, 0);
  rb_define_method(rb_cTilemap, "flash_data=", rb_tilemap_m_set_flash_data, 1);
#if RGSS == 3
  rb_define_method(rb_cTilemap, "flags", rb_tilemap_m_flags, 0);
  rb_define_method(rb_cTilemap, "flags=", rb_tilemap_m_set_flags, 1);
#elif RGSS == 2
  rb_define_method(rb_cTilemap, "passages", rb_tilemap_m_flags, 0);
  rb_define_method(rb_cTilemap, "passages=", rb_tilemap_m_set_flags, 1);
#else
  rb_define_method(rb_cTilemap, "priorities", rb_tilemap_m_priorities, 0);
  rb_define_method(rb_cTilemap, "priorities=", rb_tilemap_m_set_priorities, 1);
#endif
  rb_define_method(rb_cTilemap, "viewport", rb_tilemap_m_viewport, 0);
#if RGSS >= 2
  rb_define_method(rb_cTilemap, "viewport=", rb_tilemap_m_set_viewport, 1);
#endif
  rb_define_method(rb_cTilemap, "visible", rb_tilemap_m_visible, 0);
  rb_define_method(rb_cTilemap, "visible=", rb_tilemap_m_set_visible, 1);
  rb_define_method(rb_cTilemap, "ox", rb_tilemap_m_ox, 0);
  rb_define_method(rb_cTilemap, "ox=", rb_tilemap_m_set_ox, 1);
  rb_define_method(rb_cTilemap, "oy", rb_tilemap_m_oy, 0);
  rb_define_method(rb_cTilemap, "oy=", rb_tilemap_m_set_oy, 1);
}

bool rb_tilemap_data_p(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))tilemap_mark;
}

const struct Tilemap *rb_tilemap_data(VALUE obj) {
  Check_Type(obj, T_DATA);
  // Note: original RGSS doesn't check types.
  if(RDATA(obj)->dmark != (void(*)(void*))tilemap_mark) {
    rb_raise(rb_eTypeError,
        "can't convert %s into Tilemap",
        rb_class2name(rb_obj_class(obj)));
  }
  struct Tilemap *ret;
  Data_Get_Struct(obj, struct Tilemap, ret);
  return ret;
}

struct Tilemap *rb_tilemap_data_mut(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Tilemap");
  return (struct Tilemap *)rb_tilemap_data(obj);
}

static void tilemap_mark(struct Tilemap *ptr) {
#if RGSS >= 2
  rb_gc_mark(ptr->bitmaps);
  rb_gc_mark(ptr->flags);
#else
  rb_gc_mark(ptr->autotiles);
  rb_gc_mark(ptr->tileset);
  rb_gc_mark(ptr->priorities);
#endif
  rb_gc_mark(ptr->map_data);
  rb_gc_mark(ptr->flash_data);
  rb_gc_mark(ptr->viewport);
}

static void tilemap_free(struct Tilemap *ptr) {
  disposeRenderable(&ptr->renderable);
  xfree(ptr);
}

static VALUE tilemap_alloc(VALUE klass) {
  struct Tilemap *ptr = ALLOC(struct Tilemap);
  ptr->renderable.clear = NULL;
  ptr->renderable.prepare = prepareRenderTilemap;
  ptr->renderable.render = renderTilemap;
  ptr->renderable.disposed = false;
#if RGSS >= 2
  ptr->bitmaps = Qnil;
#else
  ptr->tileset = Qnil;
  ptr->autotiles = Qnil;
#endif
  ptr->map_data = Qnil;
  ptr->flash_data = Qnil;
#if RGSS >= 2
  ptr->flags = Qnil;
#else
  ptr->priorities = Qnil;
#endif
  ptr->viewport = Qnil;
  ptr->visible = true;
  ptr->ox = 0;
  ptr->oy = 0;
  ptr->autotile_tick = 0;
  VALUE ret = Data_Wrap_Struct(klass, tilemap_mark, tilemap_free, ptr);
#if RGSS >= 2
  ptr->bitmaps = rb_bitmaparray_new();
#else
  ptr->autotiles = rb_bitmaparray_new();
#endif
  registerRenderable(&ptr->renderable);
  return ret;
}

/*
 * call-seq:
 *   Tilemap.new
 *   Tilemap.new(viewport)
 *
 * Creates new tilemap object, possibly with viewport.
 */
static VALUE rb_tilemap_m_initialize(int argc, VALUE *argv, VALUE self) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  switch(argc) {
    case 0:
      break;
    case 1:
      if(argv[0] != Qnil) rb_viewport_data(argv[0]);
      ptr->viewport = argv[0];
      break;
    default:
      rb_raise(rb_eArgError,
          "wrong number of arguments (%d for 0..1)", argc);
      break;
  }
  return Qnil;
}

static VALUE rb_tilemap_m_initialize_copy(VALUE self, VALUE orig) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  const struct Tilemap *orig_ptr = rb_tilemap_data(orig);
#if RGSS >= 2
  rb_bitmaparray_set2(ptr->bitmaps, orig_ptr->bitmaps);
#else
  ptr->tileset = orig_ptr->tileset;
  rb_bitmaparray_set2(ptr->autotiles, orig_ptr->autotiles);
#endif
  ptr->map_data = orig_ptr->map_data;
  ptr->flash_data = orig_ptr->flash_data;
#if RGSS >= 2
  ptr->flags = orig_ptr->flags;
#else
  ptr->priorities = orig_ptr->priorities;
#endif
  ptr->viewport = orig_ptr->viewport;
  ptr->visible = orig_ptr->visible;
  ptr->ox = orig_ptr->ox;
  ptr->oy = orig_ptr->oy;
  ptr->autotile_tick = orig_ptr->autotile_tick;
  return Qnil;
}

static VALUE rb_tilemap_m_dispose(VALUE self) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  disposeRenderable(&ptr->renderable);
  return Qnil;
}

static VALUE rb_tilemap_m_disposed_p(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->renderable.disposed ? Qtrue : Qfalse;
}

static VALUE rb_tilemap_m_update(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  (void) ptr;
  WARN_UNIMPLEMENTED("Tilemap#update");
  return Qnil;
}
#if RGSS >= 2
static VALUE rb_tilemap_m_bitmaps(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->bitmaps;
}
#else
static VALUE rb_tilemap_m_tileset(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->tileset;
}

static VALUE rb_tilemap_m_set_tileset(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  if(newval != Qnil) rb_bitmap_data(newval);
  ptr->tileset = newval;
  return newval;
}

static VALUE rb_tilemap_m_autotiles(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->autotiles;
}
#endif

static VALUE rb_tilemap_m_map_data(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->map_data;
}

static VALUE rb_tilemap_m_set_map_data(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  if(newval != Qnil) rb_table_data(newval);
  ptr->map_data = newval;
  return newval;
}

static VALUE rb_tilemap_m_flash_data(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->flash_data;
}

static VALUE rb_tilemap_m_set_flash_data(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  if(newval != Qnil) rb_table_data(newval);
  ptr->flash_data = newval;
  return newval;
}

#if RGSS >= 2
static VALUE rb_tilemap_m_flags(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->flags;
}

static VALUE rb_tilemap_m_set_flags(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  if(newval != Qnil) rb_table_data(newval);
  ptr->flags = newval;
  return newval;
}
#else
static VALUE rb_tilemap_m_priorities(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->priorities;
}

static VALUE rb_tilemap_m_set_priorities(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  if(newval != Qnil) rb_table_data(newval);
  ptr->priorities = newval;
  return newval;
}
#endif

static VALUE rb_tilemap_m_viewport(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->viewport;
}

#if RGSS >= 2
static VALUE rb_tilemap_m_set_viewport(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  if(newval != Qnil) rb_viewport_data(newval);
  ptr->viewport = newval;
  return newval;
}
#endif

static VALUE rb_tilemap_m_visible(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->visible ? Qtrue : Qfalse;
}

static VALUE rb_tilemap_m_set_visible(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  ptr->visible = RTEST(newval);
  return newval;
}

static VALUE rb_tilemap_m_ox(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return INT2NUM(ptr->ox);
}

static VALUE rb_tilemap_m_set_ox(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  ptr->ox = NUM2INT(newval);
  return newval;
}

static VALUE rb_tilemap_m_oy(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return INT2NUM(ptr->oy);
}

static VALUE rb_tilemap_m_set_oy(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  ptr->oy = NUM2INT(newval);
  return newval;
}

static void prepareRenderTilemap(struct Renderable *renderable, int t) {
  struct Tilemap *ptr = (struct Tilemap *)renderable;
  if(!ptr->visible) return;
  struct RenderJob job;
  job.renderable = renderable;
  job.t = t;
#if RGSS >= 2
  job.z = 0;
  job.y = 0;
  job.aux[0] = 0;
  job.aux[1] = 0;
  job.aux[2] = 0;
  queueRenderJob(ptr->viewport, job);
  job.z = 200;
  job.y = 0;
  job.aux[0] = 1;
  queueRenderJob(ptr->viewport, job);
#else
  if(ptr->map_data == Qnil) return;
  const struct Table *map_data_ptr = rb_table_data(ptr->map_data);
  int xsize = map_data_ptr->xsize;
  int ysize = map_data_ptr->ysize;
  int zsize = map_data_ptr->zsize;

  const struct Table *priorities_ptr = NULL;
  if(ptr->priorities != Qnil) rb_table_data(ptr->priorities);

  // TODO respect Viewport width
  int x_start = ptr->ox >> 5;
  int x_end = (ptr->ox + window_width + 31) >> 5;
  int y_start = ptr->oy >> 5;
  int y_end = (ptr->oy + window_height + 31) >> 5;

  for(int zi = 0; zi < zsize; ++zi) {
    for(int yi = y_start; yi <= y_end; ++yi) {
      for(int xi = x_start; xi <= x_end; ++xi) {
        if(zi > 3) continue;

        int xii = (xi % xsize + xsize) % xsize;
        int yii = (yi % ysize + ysize) % ysize;
        int tile_id = map_data_ptr->data[(zi * ysize + yii) * xsize + xii];

        int priority = 0, z = 0;
        if(priorities_ptr && 0 <= tile_id && tile_id < priorities_ptr->size) {
          priority = priorities_ptr->data[tile_id];
        }
        if(priority > 0) {
          z = (1 + priority + yi) * 32 - ptr->oy;
        }

        job.z = z;
        job.y = 0;
        job.aux[0] = xii;
        job.aux[1] = yii;
        job.aux[2] = zi;
        queueRenderJob(ptr->viewport, job);
      }
    }
  }
#endif
}
static void renderTilemap(
    struct Renderable *renderable, const struct RenderJob *job,
    const struct RenderViewport *viewport) {
  struct Tilemap *ptr = (struct Tilemap *)renderable;
#if RGSS >= 2
  if(ptr->map_data == Qnil) return;
  const struct Table *map_data_ptr = rb_table_data(ptr->map_data);
  int xsize = map_data_ptr->xsize;
  int ysize = map_data_ptr->ysize;
  int zsize = map_data_ptr->zsize;

  const struct Table *flags_ptr = NULL;
  if(ptr->flags != Qnil) flags_ptr = rb_table_data(ptr->flags);

  int x_start = (viewport->ox + ptr->ox) >> 5;
  int x_end = (viewport->ox + ptr->ox + viewport->width + 31) >> 5;
  int y_start = (viewport->oy + ptr->oy) >> 5;
  int y_end = (viewport->oy + ptr->oy + viewport->height + 31) >> 5;

  for(int zi = 0; zi < zsize; ++zi) {
    for(int yi = y_start; yi <= y_end; ++yi) {
      for(int xi = x_start; xi <= x_end; ++xi) {
        // TODO: shadow
        if(zi == 3) continue;

        int xii = (xi % xsize + xsize) % xsize;
        int yii = (yi % ysize + ysize) % ysize;
        int tile_id = map_data_ptr->data[(zi * ysize + yii) * xsize + xii];

        int z = 0;
        if(zi == 2 && flags_ptr && 0 <= tile_id && tile_id < flags_ptr->size) {
          z = (flags_ptr->data[tile_id] & 0x10) ? 200 : 0;
        }
        if(z != job->z) continue;
        renderTile(ptr, tile_id, xi * 32 - ptr->ox, yi * 32 - ptr->oy,
            viewport);
      }
    }
  }
#else
  if(ptr->map_data == Qnil) return;
  const struct Table *map_data_ptr = rb_table_data(ptr->map_data);
  int xsize = map_data_ptr->xsize;
  int ysize = map_data_ptr->ysize;

  int xi = job->aux[0];
  int yi = job->aux[1];
  int zi = job->aux[2];
  int xii = (xi % xsize + xsize) % xsize;
  int yii = (yi % ysize + ysize) % ysize;
  int tile_id = map_data_ptr->data[(zi * ysize + yii) * xsize + xii];
  renderTile(ptr, tile_id, xi * 32 - ptr->ox, yi * 32 - ptr->oy, viewport);
#endif
}

#if RGSS >= 2
#define AUTOTILE_HALF_X 4
static const int autotile_lookup[4][96] = {
  { 18,  2, 18,  2, 18,  2, 18,  2, 18,  2, 18,  2, 18,  2, 18,  2,
    16, 16, 16, 16, 10, 10, 10, 10, 18, 18,  2,  2, 18,  2, 18,  2,
    16, 10,  8,  8, 10, 10, 18,  2, 16, 16,  8,  8, 16, 10,  8,  0,
    10,  8,  2,  0, 10,  8,  2,  0, 10,  8,  2,  0, 10,  8,  2,  0},
  { 17, 17,  3,  3, 17, 17,  3,  3, 17, 17,  3,  3, 17, 17,  3,  3,
    17,  3, 17,  3,  9,  9,  9,  9, 19, 19, 19, 19, 17, 17,  3,  3,
    19,  9,  9,  9, 11, 11, 19, 19, 17,  3, 11,  9, 19, 11, 11,  1,
     9,  9,  1,  1, 11, 11,  3,  3,  9,  9,  1,  1, 11, 11,  3,  3},
  { 14, 14, 14, 14, 14, 14, 14, 14,  6,  6,  6,  6,  6,  6,  6,  6,
    12, 12, 12, 12, 14, 14,  6,  6, 14,  6, 14,  6, 22, 22, 22, 22,
    12, 22, 12, 12, 14,  6, 22, 22, 20, 20, 12, 20, 20, 22, 20,  4,
     6,  4,  6,  4,  6,  4,  6,  4, 14, 12, 14, 12, 14, 12, 14, 12},
  { 13, 13, 13, 13,  7,  7,  7,  7, 13, 13, 13, 13,  7,  7,  7,  7,
    13, 13,  7,  7, 13,  7, 13,  7, 15, 15, 15, 15, 21, 21, 21, 21,
    15, 21, 13,  7, 15, 15, 23, 23, 21, 21, 15, 21, 23, 23, 23,  5,
     5,  5,  5,  5,  7,  7,  7,  7, 13, 13, 13, 13, 15, 15, 15, 15}};
static const int counter_alternatives[24] = {
  -1, -1, -1, -1, 12, 15, 14, 13, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, 12, 13, 14, 15
};
#else
#define AUTOTILE_HALF_X 6
static const int autotile_lookup[4][48] = {
  { 26,  4, 26,  4, 26,  4, 26,  4, 26,  4, 26,  4, 26,  4, 26,  4,
    24, 24, 24, 24, 14, 14, 14, 14, 28, 28,  4,  4, 38,  4, 38,  4,
    24, 14, 12, 12, 16, 16, 40,  4, 36, 36, 12, 12, 36, 16, 12,  0},
  { 27, 27,  5,  5, 27, 27,  5,  5, 27, 27,  5,  5, 27, 27,  5,  5,
    25,  5, 25,  5, 15, 15, 15, 15, 29, 29, 29, 29, 39, 39,  5,  5,
    29, 15, 13, 13, 17, 17, 41, 41, 37,  5, 17, 13, 41, 17, 17,  1},
  { 32, 32, 32, 32, 32, 32, 32, 32, 10, 10, 10, 10, 10, 10, 10, 10,
    30, 30, 30, 30, 20, 20, 10, 10, 34, 10, 34, 10, 44, 44, 44, 44,
    30, 44, 18, 18, 22, 10, 46, 46, 42, 42, 18, 42, 42, 46, 42,  6},
  { 33, 33, 33, 33, 11, 11, 11, 11, 33, 33, 33, 33, 11, 11, 11, 11,
    31, 31, 11, 11, 21, 11, 21, 11, 35, 35, 35, 35, 45, 45, 45, 45,
    35, 45, 19, 11, 23, 23, 47, 47, 43, 43, 23, 43, 47, 47, 47,  7}
};
static const int counter_alternatives[48] = {
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
};
#endif

static void renderTile(struct Tilemap *ptr, int tile_id, int x, int y,
    const struct RenderViewport *viewport) {
  VALUE tileset = Qnil;
  int autotile_shape_id = -1;
  bool is_counter = false;
  int src_x, src_y;
#if RGSS >= 2
  int bitmapid = -1;
  if(0 < tile_id && tile_id < 1024) {
    // Tileset B, C, D, E
    bitmapid = 5 + ((tile_id>>8)&3);
    src_x = ((tile_id&7)|((tile_id>>4)&8)) * 32;
    src_y = ((tile_id>>3)&15) * 32;
  } else if(1536 <= tile_id && tile_id < 1664) {
    // Tileset A5
    bitmapid = 4;
    src_x = (tile_id - 1536) % 8 * 32;
    src_y = (tile_id - 1536) / 8 % 16 * 32;
  } else if(2048 <= tile_id && tile_id < 8192) {
    // Autotile -- Tileset A1, A2, A3, A4
    // Autotile has 47+1 shapes
    int autotile_id = (tile_id - 2048) / 48;
    autotile_shape_id = (tile_id - 2048) % 48;
    int autotile_x, autotile_y;

    const struct Table *flags_ptr = NULL;
    if(ptr->flags != Qnil) flags_ptr = rb_table_data(ptr->flags);
    if(flags_ptr && tile_id < flags_ptr->size) {
      is_counter = flags_ptr->data[tile_id] & 0x80;
    }

    if(autotile_id < 16) {
      // Tileset A1
      bitmapid = 0;
      // Swap autotile 1 and 2
      if(autotile_id == 1 || autotile_id == 2) autotile_id ^= 3;

      // Complex reordering
      int id0 = autotile_id % 2;
      int id1 = autotile_id / 2 % 2;
      int id2 = autotile_id / 4 % 2;
      int id3 = autotile_id / 8;
      if(id0 == 0) {
        autotile_x = id2 * 8 + ptr->autotile_tick % 3 * 2;
      } else {
        autotile_x = id2 * 8 + 3 * 2;
      }
      autotile_y = (id1 + id3 * 2) * 3;
    } else if(autotile_id < 48) {
      // Tileset A2
      bitmapid = 1;

      autotile_x = (autotile_id - 16) % 8 * 2;
      autotile_y = (autotile_id - 16) / 8 * 3;
    } else if(autotile_id < 80) {
      // Tileset A3
      bitmapid = 2;

      // Use a different autotile pattern
      autotile_shape_id += 48;

      autotile_x = (autotile_id - 48) % 8 * 2;
      autotile_y = (autotile_id - 48) / 8 % 4 * 2;
    } else {
      // Tileset A4
      bitmapid = 3;

      int id0 = (autotile_id - 80) % 8;
      int id1 = (autotile_id - 80) / 8 % 2;
      int id2 = (autotile_id - 80) / 16;

      autotile_x = id0 * 2;
      autotile_y = id2 * 5;
      if(id1) {
        // Use a different autotile pattern
        autotile_shape_id += 48;
        autotile_y += 3;
      }
    }

    src_x = autotile_x * 32;
    src_y = autotile_y * 32;
  } else {
    return;
  }
  const struct BitmapArray *bitmaparray_ptr =
    rb_bitmaparray_data(ptr->bitmaps);
  tileset = bitmaparray_ptr->data[bitmapid];
#else
  if(tile_id < 48) return;
  if(tile_id < 384) {
    int autotile_id = tile_id / 48 - 1;
    autotile_shape_id = tile_id % 48;

    const struct BitmapArray *bitmaparray_ptr =
      rb_bitmaparray_data(ptr->autotiles);
    tileset = bitmaparray_ptr->data[autotile_id];

    // TODO: animation
    src_x = 0;
    src_y = 0;
  } else {
    tileset = ptr->tileset;
    src_x = (tile_id - 384) % 8 * 32;
    src_y = (tile_id - 384) / 8 * 32;
  }
#endif

  if(tileset == Qnil) return;
  const struct Bitmap *tileset_ptr = rb_bitmap_data(tileset);
  SDL_Surface *tileset_surface = tileset_ptr->surface;
  if(!tileset_surface) return;

  glEnable(GL_BLEND);
  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
  glBlendEquation(GL_FUNC_ADD);

  glUseProgram(shader);
  glUniform1i(glGetUniformLocation(shader, "tex"), 0);
  glUniform2f(glGetUniformLocation(shader, "resolution"),
      viewport->width, viewport->height);

  glActiveTexture(GL_TEXTURE0);
  bitmapBindTexture((struct Bitmap *)tileset_ptr);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  if(autotile_shape_id != -1) {
    for(int i = 0; i < 4; ++i) {
      int autotile_shape_orig = autotile_lookup[i][autotile_shape_id];
      int autotile_shapes[2] = {autotile_shape_orig, 0};
      int counter_repeat = 1;
      if(is_counter && counter_alternatives[autotile_shape_orig] != -1) {
        autotile_shapes[0] = counter_alternatives[autotile_shape_orig];
        autotile_shapes[1] = autotile_shape_orig;
        counter_repeat = 2;
      }
      for(int j = 0; j < counter_repeat; ++j) {
        int autotile_shape = autotile_shapes[j];
        int src_xi = src_x + autotile_shape % AUTOTILE_HALF_X * 16;
        int src_yi = src_y + autotile_shape / AUTOTILE_HALF_X * 16;
        int dst_x = x + (i % 2) * 16;
        int dst_y = y + (i / 2) * 16;
        gl_draw_rect(
            -viewport->ox + dst_x, dst_y + j * 8,
            -viewport->oy + dst_x + 16, dst_y + 16 + j * 8,
            -viewport->ox + src_xi / (double)tileset_surface->w,
            -viewport->oy + src_yi / (double)tileset_surface->h,
            (src_xi + 16) / (double)tileset_surface->w,
            (src_yi + 16) / (double)tileset_surface->h);
      }
    }
  } else {
    gl_draw_rect(
        -viewport->ox + x,
        -viewport->oy + y,
        -viewport->ox + x + 32,
        -viewport->oy + y + 32,
        src_x / (double)tileset_surface->w,
        src_y / (double)tileset_surface->h,
        (src_x + 32) / (double)tileset_surface->w,
        (src_y + 32) / (double)tileset_surface->h);
  }
}

void initTilemapSDL() {
  static const char *vsh_source =
    "#version 120\n"
    "\n"
    "uniform vec2 resolution;\n"
    "\n"
    "void main(void) {\n"
    "    gl_TexCoord[0] = gl_MultiTexCoord0;\n"
    "    gl_Position.x = gl_Vertex.x / resolution.x * 2.0 - 1.0;\n"
    "    gl_Position.y = 1.0 - gl_Vertex.y / resolution.y * 2.0;\n"
    "    gl_Position.zw = vec2(0.0, 1.0);\n"
    "}\n";

  static const char *fsh_source =
    "#version 120\n"
    "#if __VERSION__ >= 130\n"
    "#define texture2D texture\n"
    "#define texture2DProj textureProj\n"
    "#endif\n"
    "\n"
    "uniform sampler2D windowskin;\n"
    "\n"
    "void main(void) {\n"
    "    vec4 color = texture2D(windowskin, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y));\n"
    "    gl_FragColor = color;\n"
    "    /* premultiplication */\n"
    "    gl_FragColor.rgb *= gl_FragColor.a;\n"
    "}\n";

  shader = compileShaders(vsh_source, fsh_source);
}

void deinitTilemapSDL() {
  if(shader) glDeleteProgram(shader);
}
