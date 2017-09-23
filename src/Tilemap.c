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

static void registerTilemap(struct Tilemap *ptr) {
  (void) ptr;
  WARN_UNIMPLEMENTED("registerTilemap");
}

static void unregisterTilemap(struct Tilemap *ptr) {
  (void) ptr;
  WARN_UNIMPLEMENTED("unregisterTilemap");
}

void renderTilemaps(void) {
  WARN_UNIMPLEMENTED("renderTilemaps");
}

void initTilemapSDL() {
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
    // "uniform vec4 tilemap_color;\n"
    // "uniform vec4 tilemap_tone;\n"
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

void deinitTilemapSDL() {
  if(shader) glDeleteProgram(shader);
}
