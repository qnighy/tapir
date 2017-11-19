// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "Plane.h"
#include <SDL.h>
#include "gl_misc.h"
#include "Bitmap.h"
#include "Viewport.h"
#include "Rect.h"
#include "Color.h"
#include "Tone.h"
#include "misc.h"

static GLuint shader;

static void plane_mark(struct Plane *ptr);
static void plane_free(struct Plane *ptr);
static VALUE plane_alloc(VALUE klass);

static VALUE rb_plane_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_plane_m_initialize_copy(VALUE self, VALUE orig);

static VALUE rb_plane_m_dispose(VALUE self);
static VALUE rb_plane_m_disposed_p(VALUE self);
static VALUE rb_plane_m_bitmap(VALUE self);
static VALUE rb_plane_m_set_bitmap(VALUE self, VALUE bitmap);
static VALUE rb_plane_m_viewport(VALUE self);
#if RGSS >= 2
static VALUE rb_plane_m_set_viewport(VALUE self, VALUE newval);
#endif
static VALUE rb_plane_m_visible(VALUE self);
static VALUE rb_plane_m_set_visible(VALUE self, VALUE newval);
static VALUE rb_plane_m_z(VALUE self);
static VALUE rb_plane_m_set_z(VALUE self, VALUE newval);
static VALUE rb_plane_m_ox(VALUE self);
static VALUE rb_plane_m_set_ox(VALUE self, VALUE newval);
static VALUE rb_plane_m_oy(VALUE self);
static VALUE rb_plane_m_set_oy(VALUE self, VALUE newval);
static VALUE rb_plane_m_zoom_x(VALUE self);
static VALUE rb_plane_m_set_zoom_x(VALUE self, VALUE newval);
static VALUE rb_plane_m_zoom_y(VALUE self);
static VALUE rb_plane_m_set_zoom_y(VALUE self, VALUE newval);
static VALUE rb_plane_m_opacity(VALUE self);
static VALUE rb_plane_m_set_opacity(VALUE self, VALUE newval);
static VALUE rb_plane_m_blend_type(VALUE self);
static VALUE rb_plane_m_set_blend_type(VALUE self, VALUE newval);
static VALUE rb_plane_m_color(VALUE self);
static VALUE rb_plane_m_set_color(VALUE self, VALUE newval);
static VALUE rb_plane_m_tone(VALUE self);
static VALUE rb_plane_m_set_tone(VALUE self, VALUE newval);

static void prepareRenderPlane(struct Renderable *renderable, int t);
static void renderPlane(
    struct Renderable *renderable, const struct RenderJob *job,
    const struct RenderViewport *viewport);

VALUE rb_cPlane;

/*
 * A graphic object containing a bitmap.
 */
void Init_Plane(void) {
  rb_cPlane = rb_define_class("Plane", rb_cObject);
  rb_define_alloc_func(rb_cPlane, plane_alloc);
  rb_define_private_method(rb_cPlane, "initialize",
      rb_plane_m_initialize, -1);
  rb_define_private_method(rb_cPlane, "initialize_copy",
      rb_plane_m_initialize_copy, 1);
  rb_define_method(rb_cPlane, "dispose", rb_plane_m_dispose, 0);
  rb_define_method(rb_cPlane, "disposed?", rb_plane_m_disposed_p, 0);
  rb_define_method(rb_cPlane, "bitmap", rb_plane_m_bitmap, 0);
  rb_define_method(rb_cPlane, "bitmap=", rb_plane_m_set_bitmap, 1);
  rb_define_method(rb_cPlane, "viewport", rb_plane_m_viewport, 0);
#if RGSS >= 2
  rb_define_method(rb_cPlane, "viewport=", rb_plane_m_set_viewport, 1);
#endif
  rb_define_method(rb_cPlane, "visible", rb_plane_m_visible, 0);
  rb_define_method(rb_cPlane, "visible=", rb_plane_m_set_visible, 1);
  rb_define_method(rb_cPlane, "z", rb_plane_m_z, 0);
  rb_define_method(rb_cPlane, "z=", rb_plane_m_set_z, 1);
  rb_define_method(rb_cPlane, "ox", rb_plane_m_ox, 0);
  rb_define_method(rb_cPlane, "ox=", rb_plane_m_set_ox, 1);
  rb_define_method(rb_cPlane, "oy", rb_plane_m_oy, 0);
  rb_define_method(rb_cPlane, "oy=", rb_plane_m_set_oy, 1);
  rb_define_method(rb_cPlane, "zoom_x", rb_plane_m_zoom_x, 0);
  rb_define_method(rb_cPlane, "zoom_x=", rb_plane_m_set_zoom_x, 1);
  rb_define_method(rb_cPlane, "zoom_y", rb_plane_m_zoom_y, 0);
  rb_define_method(rb_cPlane, "zoom_y=", rb_plane_m_set_zoom_y, 1);
  rb_define_method(rb_cPlane, "opacity", rb_plane_m_opacity, 0);
  rb_define_method(rb_cPlane, "opacity=", rb_plane_m_set_opacity, 1);
  rb_define_method(rb_cPlane, "blend_type", rb_plane_m_blend_type, 0);
  rb_define_method(rb_cPlane, "blend_type=", rb_plane_m_set_blend_type, 1);
  rb_define_method(rb_cPlane, "color", rb_plane_m_color, 0);
  rb_define_method(rb_cPlane, "color=", rb_plane_m_set_color, 1);
  rb_define_method(rb_cPlane, "tone", rb_plane_m_tone, 0);
  rb_define_method(rb_cPlane, "tone=", rb_plane_m_set_tone, 1);
}

bool rb_plane_data_p(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))plane_mark;
}

const struct Plane *rb_plane_data(VALUE obj) {
  Check_Type(obj, T_DATA);
  // Note: original RGSS doesn't check types.
  if(RDATA(obj)->dmark != (void(*)(void*))plane_mark) {
    rb_raise(rb_eTypeError,
        "can't convert %s into Plane",
        rb_class2name(rb_obj_class(obj)));
  }
  struct Plane *ret;
  Data_Get_Struct(obj, struct Plane, ret);
  return ret;
}

struct Plane *rb_plane_data_mut(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Plane");
  return (struct Plane *)rb_plane_data(obj);
}

static void plane_mark(struct Plane *ptr) {
  rb_gc_mark(ptr->viewport);
  rb_gc_mark(ptr->bitmap);
  rb_gc_mark(ptr->color);
  rb_gc_mark(ptr->tone);
}

static void plane_free(struct Plane *ptr) {
  disposeRenderable(&ptr->renderable);
  xfree(ptr);
}

static VALUE plane_alloc(VALUE klass) {
  struct Plane *ptr = ALLOC(struct Plane);
  ptr->renderable.clear = NULL;
  ptr->renderable.prepare = prepareRenderPlane;
  ptr->renderable.render = renderPlane;
  ptr->renderable.disposed = false;
  ptr->bitmap = Qnil;
  ptr->viewport = Qnil;
  ptr->visible = true;
  ptr->z = 0;
  ptr->ox = 0;
  ptr->oy = 0;
  ptr->zoom_x = 1.0;
  ptr->zoom_y = 1.0;
  ptr->opacity = 255;
  ptr->blend_type = 0;
  ptr->color = Qnil;
  ptr->tone = Qnil;
  VALUE ret = Data_Wrap_Struct(klass, plane_mark, plane_free, ptr);
  ptr->color = rb_color_new2();
  ptr->tone = rb_tone_new2();
  registerRenderable(&ptr->renderable);
  return ret;
}

/*
 * call-seq:
 *   Plane.new
 *   Plane.new(viewport)
 *
 * Creates new plane object, possibly with viewport.
 */
static VALUE rb_plane_m_initialize(int argc, VALUE *argv, VALUE self) {
  struct Plane *ptr = rb_plane_data_mut(self);
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

static VALUE rb_plane_m_initialize_copy(VALUE self, VALUE orig) {
  struct Plane *ptr = rb_plane_data_mut(self);
  const struct Plane *orig_ptr = rb_plane_data(orig);
  ptr->bitmap = orig_ptr->bitmap;
  ptr->viewport = orig_ptr->viewport;
  ptr->visible = orig_ptr->visible;
  ptr->z = orig_ptr->z;
  ptr->ox = orig_ptr->ox;
  ptr->oy = orig_ptr->oy;
  ptr->zoom_x = orig_ptr->zoom_x;
  ptr->zoom_y = orig_ptr->zoom_y;
  ptr->opacity = orig_ptr->opacity;
  ptr->blend_type = orig_ptr->blend_type;
  rb_color_set2(ptr->color, orig_ptr->color);
  rb_tone_set2(ptr->tone, orig_ptr->tone);
  return Qnil;
}

static VALUE rb_plane_m_dispose(VALUE self) {
  struct Plane *ptr = rb_plane_data_mut(self);
  disposeRenderable(&ptr->renderable);
  return Qnil;
}

static VALUE rb_plane_m_disposed_p(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return ptr->renderable.disposed ? Qtrue : Qfalse;
}

static VALUE rb_plane_m_bitmap(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return ptr->bitmap;
}

static VALUE rb_plane_m_set_bitmap(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  if(newval != Qnil) rb_bitmap_data(newval);
  ptr->bitmap = newval;
  return newval;
}

static VALUE rb_plane_m_viewport(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return ptr->viewport;
}

#if RGSS >= 2
static VALUE rb_plane_m_set_viewport(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  if(newval != Qnil) rb_viewport_data(newval);
  ptr->viewport = newval;
  return newval;
}
#endif

static VALUE rb_plane_m_visible(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return ptr->visible ? Qtrue : Qfalse;
}

static VALUE rb_plane_m_set_visible(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  ptr->visible = RTEST(newval);
  return newval;
}

static VALUE rb_plane_m_z(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return INT2NUM(ptr->z);
}

static VALUE rb_plane_m_set_z(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  ptr->z = NUM2INT(newval);
  return newval;
}

static VALUE rb_plane_m_ox(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return INT2NUM(ptr->ox);
}

static VALUE rb_plane_m_set_ox(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  ptr->ox = NUM2INT(newval);
  return newval;
}

static VALUE rb_plane_m_oy(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return INT2NUM(ptr->oy);
}

static VALUE rb_plane_m_set_oy(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  ptr->oy = NUM2INT(newval);
  return newval;
}

static VALUE rb_plane_m_zoom_x(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return DBL2NUM(ptr->zoom_x);
}

static VALUE rb_plane_m_set_zoom_x(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  ptr->zoom_x = NUM2DBL(newval);
  return newval;
}

static VALUE rb_plane_m_zoom_y(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return DBL2NUM(ptr->zoom_y);
}

static VALUE rb_plane_m_set_zoom_y(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  ptr->zoom_y = NUM2DBL(newval);
  return newval;
}

static VALUE rb_plane_m_opacity(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return INT2NUM(ptr->opacity);
}

static VALUE rb_plane_m_set_opacity(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  ptr->opacity = saturateInt32(NUM2INT(newval), 0, 255);
  return newval;
}

static VALUE rb_plane_m_blend_type(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return INT2NUM(ptr->blend_type);
}

static VALUE rb_plane_m_set_blend_type(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  /* TODO: check range */
  ptr->blend_type = NUM2INT(newval);
  return newval;
}

static VALUE rb_plane_m_color(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return ptr->color;
}

static VALUE rb_plane_m_set_color(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  rb_color_set2(ptr->color, newval);
  return newval;
}
static VALUE rb_plane_m_tone(VALUE self) {
  const struct Plane *ptr = rb_plane_data(self);
  return ptr->tone;
}

static VALUE rb_plane_m_set_tone(VALUE self, VALUE newval) {
  struct Plane *ptr = rb_plane_data_mut(self);
  rb_tone_set2(ptr->tone, newval);
  return newval;
}

static void prepareRenderPlane(struct Renderable *renderable, int t) {
  struct Plane *ptr = (struct Plane *)renderable;
  if(!ptr->visible) return;
  struct RenderJob job;
  job.renderable = renderable;
  job.z = ptr->z;
  job.y = 0;
  job.aux[0] = 0;
  job.aux[1] = 0;
  job.aux[2] = 0;
  job.t = t;
  queueRenderJob(ptr->viewport, job);
}

static void renderPlane(
    struct Renderable *renderable, const struct RenderJob *job,
    const struct RenderViewport *viewport) {
  (void) job;
  struct Plane *ptr = (struct Plane *)renderable;
  {
    const struct Color *color = rb_color_data(ptr->color);
    if(color->red || color->green || color->blue || color->alpha) {
      WARN_UNIMPLEMENTED("Plane#color");
    }
  }
  {
    const struct Tone *tone = rb_tone_data(ptr->tone);
    if(tone->red || tone->green || tone->blue || tone->gray) {
      WARN_UNIMPLEMENTED("Plane#tone");
    }
  }
  if(ptr->opacity == 0) return;
  if(ptr->bitmap == Qnil) return;
  const struct Bitmap *bitmap_ptr = rb_bitmap_data(ptr->bitmap);
  SDL_Surface *surface = bitmap_ptr->surface;
  if(!surface) return;

  glEnable(GL_BLEND);
  if(ptr->blend_type == 1) {
    glBlendFuncSeparate(
        GL_ONE, GL_ONE,
        GL_ZERO, GL_ONE);
    glBlendEquation(GL_FUNC_ADD);
  } else if(ptr->blend_type == 2) {
    glBlendFuncSeparate(
        GL_ONE, GL_ONE,
        GL_ZERO, GL_ONE);
    glBlendEquationSeparate(GL_FUNC_REVERSE_SUBTRACT, GL_FUNC_ADD);
  } else {
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glBlendEquation(GL_FUNC_ADD);
  }

  glUseProgram(shader);
  glUniform1i(glGetUniformLocation(shader, "tex"), 0);
  glUniform2f(glGetUniformLocation(shader, "resolution"),
      viewport->width, viewport->height);
  glUniform2f(glGetUniformLocation(shader, "src_size"),
      surface->w, surface->h);
  glUniform2f(glGetUniformLocation(shader, "src_translate"),
      ptr->ox, ptr->oy);
  glUniform2f(glGetUniformLocation(shader, "zoom"),
      ptr->zoom_x, ptr->zoom_y);
  glUniform1f(glGetUniformLocation(shader, "opacity"),
      ptr->opacity / 255.0);

  glActiveTexture(GL_TEXTURE0);
  bitmapBindTexture((struct Bitmap *)bitmap_ptr);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  gl_draw_rect(
      0.0, 0.0, viewport->width, viewport->height,
      viewport->ox,
      viewport->oy,
      viewport->ox + viewport->width,
      viewport->oy + viewport->height);

  glUseProgram(0);
}

void initPlaneSDL() {
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
    "uniform sampler2D tex;\n"
    "uniform vec2 resolution;\n"
    "uniform vec2 src_translate;\n"
    "uniform vec2 src_size;\n"
    "uniform vec2 zoom;\n"
    "uniform float opacity;\n"
    "\n"
    "void main(void) {\n"
    "    vec2 coord = gl_TexCoord[0].xy;\n"
    "    coord = vec2(coord.x / zoom.x, coord.y / zoom.y);\n"
    "    coord = coord + src_translate;\n"
    "    coord = vec2(coord.x / src_size.x, coord.y / src_size.y);\n"
    "    coord = mod(coord, 1.0);\n"
    "    vec4 color = texture2D(tex, coord);\n"
    "    color.a *= opacity;\n"
    "    gl_FragColor = color;\n"
    "    /* premultiplication */\n"
    "    gl_FragColor.rgb *= gl_FragColor.a;\n"
    "}\n";

  shader = compileShaders(vsh_source, fsh_source);
}

void deinitPlaneSDL() {
  if(shader) glDeleteProgram(shader);
}
