#include <SDL.h>
#include "gl_misc.h"
#include "Tilemap.h"
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
#if RGSS == 3
static VALUE rb_tilemap_m_flags(VALUE self);
static VALUE rb_tilemap_m_set_flags(VALUE self, VALUE newval);
#elif RGSS == 2
static VALUE rb_tilemap_m_passages(VALUE self);
static VALUE rb_tilemap_m_set_passages(VALUE self, VALUE newval);
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

static void registerTilemap(struct Tilemap *ptr);
static void unregisterTilemap(struct Tilemap *ptr);
static void renderTilemapAt(struct Tilemap *ptr, int z_target);
static void renderTile(struct Tilemap *ptr, int tile_id, int x, int y);

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
  rb_define_method(rb_cTilemap, "passages", rb_tilemap_m_passages, 0);
  rb_define_method(rb_cTilemap, "passages=", rb_tilemap_m_set_passages, 1);
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
#if RGSS == 3
  rb_gc_mark(ptr->bitmaps);
  rb_gc_mark(ptr->flags);
#elif RGSS == 2
  rb_gc_mark(ptr->bitmaps);
  rb_gc_mark(ptr->passages);
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
  unregisterTilemap(ptr);
  xfree(ptr);
}

static VALUE tilemap_alloc(VALUE klass) {
  struct Tilemap *ptr = ALLOC(struct Tilemap);
#if RGSS >= 2
  ptr->bitmaps = rb_bitmaparray_new();
#else
  ptr->tileset = Qnil;
  ptr->autotiles = rb_bitmaparray_new();
#endif
  ptr->map_data = Qnil;
  ptr->flash_data = Qnil;
#if RGSS == 3
  ptr->flags = Qnil;
#elif RGSS == 2
  ptr->passages = Qnil;
#else
  ptr->priorities = Qnil;
#endif
  ptr->viewport = Qnil;
  ptr->visible = true;
  ptr->ox = 0;
  ptr->oy = 0;
  ptr->autotile_tick = 0;
  registerTilemap(ptr);
  VALUE ret = Data_Wrap_Struct(klass, tilemap_mark, tilemap_free, ptr);
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
#if RGSS == 3
  ptr->flags = orig_ptr->flags;
#elif RGSS == 2
  ptr->passages = orig_ptr->passages;
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
  ptr->disposed = true;
  return Qnil;
}

static VALUE rb_tilemap_m_disposed_p(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->disposed ? Qtrue : Qfalse;
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

#if RGSS == 3
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
#elif RGSS == 2
static VALUE rb_tilemap_m_passages(VALUE self) {
  const struct Tilemap *ptr = rb_tilemap_data(self);
  return ptr->passages;
}

static VALUE rb_tilemap_m_set_passages(VALUE self, VALUE newval) {
  struct Tilemap *ptr = rb_tilemap_data_mut(self);
  if(newval != Qnil) rb_table_data(newval);
  ptr->passages = newval;
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

static size_t tilemaps_size, tilemaps_capacity;
static struct Tilemap **tilemaps;

static void registerTilemap(struct Tilemap *ptr) {
  if(tilemaps_size >= tilemaps_capacity) {
    tilemaps_capacity = tilemaps_capacity + tilemaps_capacity / 2;
    tilemaps = realloc(tilemaps, sizeof(*tilemaps) * tilemaps_capacity);
  }
  tilemaps[tilemaps_size++] = ptr;
}

static void unregisterTilemap(struct Tilemap *ptr) {
  size_t i;
  for(i = 0; i < tilemaps_size; ++i) {
    if(tilemaps[i] == ptr) break;
  }
  if(i == tilemaps_size) return;
  tilemaps[i] = tilemaps[tilemaps_size - 1];
  --tilemaps_size;
}

#if RGSS >= 2
#else
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
#endif

// render tilemaps for z_min < z <= z_max.
void renderTilemaps(int z_min, int z_max) {
#if RGSS >= 2
  if(z_min < 0 && 0 <= z_max) {
    for(size_t i = 0; i < tilemaps_size; ++i) {
      renderTilemapAt(tilemaps[i], 0);
    }
  }
  if(z_min < 100 && 100 <= z_max) {
    for(size_t i = 0; i < tilemaps_size; ++i) {
      renderTilemapAt(tilemaps[i], 100);
    }
  }
#else
  if(z_min < 0 && 0 <= z_max) {
    for(size_t i = 0; i < tilemaps_size; ++i) {
      renderTilemapAt(tilemaps[i], 0);
    }
  }
  if(z_min < 0) z_min = 0;
  while(z_min < z_max) {
    // TODO how to cut z_max off
    if(z_max > window_height + 32 * 10) z_max = window_height + 32 * 10;
    int z = z_max;
    for(size_t i = 0; i < tilemaps_size; ++i) {
      int oy = tilemaps[i]->oy;
      int y = ((z_min + oy) >> 5 << 5) - oy + 32;
      if(y < z) z = y;
    }
    for(size_t i = 0; i < tilemaps_size; ++i) {
      int oy = tilemaps[i]->oy;
      int y = ((z_min + oy) >> 5 << 5) - oy + 32;
      if(y == z)  {
        renderTilemapAt(tilemaps[i], z);
      }
    }
    z_min = z;
  }
#endif
}

static void renderTilemapAt(struct Tilemap *ptr, int z_target) {
#if RGSS >= 2
  (void) ptr;
  (void) z_target;
  WARN_UNIMPLEMENTED("renderTilemapAt");
#else
  if(ptr->map_data == Qnil) return;
  const struct Table *map_data_ptr = rb_table_data(ptr->map_data);
  int xsize = map_data_ptr->xsize;
  int ysize = map_data_ptr->ysize;
  int zsize = map_data_ptr->zsize;

  const struct Table *priorities_ptr = NULL;
  if(ptr->priorities != Qnil) rb_table_data(ptr->priorities);

  int x_start = ptr->ox >> 5;
  int x_end = (ptr->ox + window_width + 31) >> 5;
  int y_start = ptr->oy >> 5;
  int y_end = (ptr->oy + window_height + 31) >> 5;

  for(int xi = x_start; xi <= x_end; ++xi) {
    for(int yi = y_start; yi <= y_end; ++yi) {
      for(int zi = 0; zi < zsize; ++zi) {
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
        if(z != z_target) continue;
        renderTile(ptr, tile_id, xi * 32 - ptr->ox, yi * 32 - ptr->oy);
      }
    }
  }
#endif
}

static void renderTile(struct Tilemap *ptr, int tile_id, int x, int y) {
#if RGSS >= 2
  (void) ptr;
  (void) tile_id;
  (void) x;
  (void) y;
  WARN_UNIMPLEMENTED("renderTile");
#else
  (void) index;
  WARN_UNIMPLEMENTED("renderTile");
  if(tile_id < 48) return;
  if(tile_id < 384) {
    int autotile_id = tile_id / 48 - 1;
    int autotile_shape_id = tile_id % 48;

    const struct BitmapArray *bitmaparray_ptr =
      rb_bitmaparray_data(ptr->autotiles);
    VALUE autotile = bitmaparray_ptr->data[autotile_id];
    if(autotile == Qnil) return;
    const struct Bitmap *autotile_ptr = rb_bitmap_data(autotile);
    SDL_Surface *autotile_surface = autotile_ptr->surface;
    if(!autotile_surface) return;

    glUseProgram(shader);
    glUniform1i(glGetUniformLocation(shader, "tex"), 0);
    glUniform2f(glGetUniformLocation(shader, "resolution"),
        window_width, window_height);

    glActiveTexture(GL_TEXTURE0);
    bitmapBindTexture((struct Bitmap *)autotile_ptr);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    for(int subtile = 0; subtile < 4; ++subtile) {
      int autotile_shape = autotile_lookup[subtile][autotile_shape_id];
      // TODO: animation
      int autotile_x = autotile_shape % 6 * 16;
      int autotile_y = autotile_shape / 6 * 16;
      int target_x = x + (subtile % 2) * 16;
      int target_y = y + (subtile / 2) * 16;
      gl_draw_rect(
          target_x, target_y, target_x + 16, target_y + 16,
          autotile_x / (double)autotile_surface->w,
          autotile_y  / (double)autotile_surface->h,
          (autotile_x + 16) / (double)autotile_surface->w,
          (autotile_y + 16) / (double)autotile_surface->h);
    }
  } else {
    if(ptr->tileset == Qnil) return;
    const struct Bitmap *tileset_ptr = rb_bitmap_data(ptr->tileset);
    SDL_Surface *tileset_surface = tileset_ptr->surface;
    if(!tileset_surface) return;

    int tile_x = (tile_id - 384) % 8;
    int tile_y = (tile_id - 384) / 8;

    glUseProgram(shader);
    glUniform1i(glGetUniformLocation(shader, "tex"), 0);
    glUniform2f(glGetUniformLocation(shader, "resolution"),
        window_width, window_height);

    glActiveTexture(GL_TEXTURE0);
    bitmapBindTexture((struct Bitmap *)tileset_ptr);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    gl_draw_rect(
        x, y, x + 32, y + 32,
        tile_x * 32 / (double)tileset_surface->w,
        tile_y * 32 / (double)tileset_surface->h,
        (tile_x + 1) * 32 / (double)tileset_surface->w,
        (tile_y + 1) * 32 / (double)tileset_surface->h);
  }
#endif
}

void initTilemapSDL() {
  tilemaps_capacity = 2;
  tilemaps = malloc(sizeof(*tilemaps) * tilemaps_capacity);

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
    "}\n";

  shader = compileShaders(vsh_source, fsh_source);
}

void deinitTilemapSDL() {
  if(shader) glDeleteProgram(shader);
  if(tilemaps) free(tilemaps);
}
