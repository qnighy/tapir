// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "Window.h"
#include <SDL.h>
#include "gl_misc.h"
#include "Bitmap.h"
#include "Viewport.h"
#include "Rect.h"
#include "Color.h"
#include "Tone.h"
#include "misc.h"

static GLuint shader1;
static GLuint shader2;
static GLuint shader3;
static GLuint shader4;
static GLuint cursor_shader;

static void window_mark(struct Window *ptr);
static void window_free(struct Window *ptr);
static VALUE window_alloc(VALUE klass);

static VALUE rb_window_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_window_m_initialize_copy(VALUE self, VALUE orig);
static VALUE rb_window_m_dispose(VALUE self);
static VALUE rb_window_m_disposed_p(VALUE self);
static VALUE rb_window_m_update(VALUE self);
#if RGSS == 3
static VALUE rb_window_m_move(
    VALUE self, VALUE x, VALUE y, VALUE width, VALUE height);
static VALUE rb_window_m_open_p(VALUE self);
static VALUE rb_window_m_close_p(VALUE self);
#endif
static VALUE rb_window_m_windowskin(VALUE self);
static VALUE rb_window_m_set_windowskin(VALUE self, VALUE newval);
static VALUE rb_window_m_contents(VALUE self);
static VALUE rb_window_m_set_contents(VALUE self, VALUE newval);
#if RGSS == 1
static VALUE rb_window_m_stretch(VALUE self);
static VALUE rb_window_m_set_stretch(VALUE self, VALUE newval);
#endif
static VALUE rb_window_m_cursor_rect(VALUE self);
static VALUE rb_window_m_set_cursor_rect(VALUE self, VALUE newval);
static VALUE rb_window_m_viewport(VALUE self);
#if RGSS >= 2
static VALUE rb_window_m_set_viewport(VALUE self, VALUE newval);
#endif
static VALUE rb_window_m_active(VALUE self);
static VALUE rb_window_m_set_active(VALUE self, VALUE newval);
static VALUE rb_window_m_visible(VALUE self);
static VALUE rb_window_m_set_visible(VALUE self, VALUE newval);
#if RGSS == 3
static VALUE rb_window_m_arrows_visible(VALUE self);
static VALUE rb_window_m_set_arrows_visible(VALUE self, VALUE newval);
#endif
static VALUE rb_window_m_pause(VALUE self);
static VALUE rb_window_m_set_pause(VALUE self, VALUE newval);
static VALUE rb_window_m_x(VALUE self);
static VALUE rb_window_m_set_x(VALUE self, VALUE newval);
static VALUE rb_window_m_y(VALUE self);
static VALUE rb_window_m_set_y(VALUE self, VALUE newval);
static VALUE rb_window_m_width(VALUE self);
static VALUE rb_window_m_set_width(VALUE self, VALUE newval);
static VALUE rb_window_m_height(VALUE self);
static VALUE rb_window_m_set_height(VALUE self, VALUE newval);
static VALUE rb_window_m_z(VALUE self);
static VALUE rb_window_m_set_z(VALUE self, VALUE newval);
static VALUE rb_window_m_ox(VALUE self);
static VALUE rb_window_m_set_ox(VALUE self, VALUE newval);
static VALUE rb_window_m_oy(VALUE self);
static VALUE rb_window_m_set_oy(VALUE self, VALUE newval);
#if RGSS == 3
static VALUE rb_window_m_padding(VALUE self);
static VALUE rb_window_m_set_padding(VALUE self, VALUE newval);
static VALUE rb_window_m_padding_bottom(VALUE self);
static VALUE rb_window_m_set_padding_bottom(VALUE self, VALUE newval);
#endif
static VALUE rb_window_m_opacity(VALUE self);
static VALUE rb_window_m_set_opacity(VALUE self, VALUE newval);
static VALUE rb_window_m_back_opacity(VALUE self);
static VALUE rb_window_m_set_back_opacity(VALUE self, VALUE newval);
static VALUE rb_window_m_contents_opacity(VALUE self);
static VALUE rb_window_m_set_contents_opacity(VALUE self, VALUE newval);
#if RGSS >= 2
static VALUE rb_window_m_openness(VALUE self);
static VALUE rb_window_m_set_openness(VALUE self, VALUE newval);
#endif
#if RGSS == 3
static VALUE rb_window_m_tone(VALUE self);
static VALUE rb_window_m_set_tone(VALUE self, VALUE newval);
#endif

static void prepareRenderWindow(struct Renderable *renderable, int t);
static void renderWindow(
    struct Renderable *renderable, const struct RenderJob *job,
    const struct RenderViewport *viewport);

VALUE rb_cWindow;

/*
 * A graphic object containing a bitmap.
 */
void Init_Window(void) {
  rb_cWindow = rb_define_class("Window", rb_cObject);
  rb_define_alloc_func(rb_cWindow, window_alloc);
  rb_define_private_method(rb_cWindow, "initialize",
      rb_window_m_initialize, -1);
  rb_define_private_method(rb_cWindow, "initialize_copy",
      rb_window_m_initialize_copy, 1);
  rb_define_method(rb_cWindow, "dispose", rb_window_m_dispose, 0);
  rb_define_method(rb_cWindow, "disposed?", rb_window_m_disposed_p, 0);
  rb_define_method(rb_cWindow, "update", rb_window_m_update, 0);
#if RGSS == 3
  rb_define_method(rb_cWindow, "move", rb_window_m_move, 4);
  rb_define_method(rb_cWindow, "open?", rb_window_m_open_p, 0);
  rb_define_method(rb_cWindow, "close?", rb_window_m_close_p, 0);
#endif
  rb_define_method(rb_cWindow, "windowskin", rb_window_m_windowskin, 0);
  rb_define_method(rb_cWindow, "windowskin=", rb_window_m_set_windowskin, 1);
  rb_define_method(rb_cWindow, "contents", rb_window_m_contents, 0);
  rb_define_method(rb_cWindow, "contents=", rb_window_m_set_contents, 1);
#if RGSS == 1
  rb_define_method(rb_cWindow, "stretch", rb_window_m_stretch, 0);
  rb_define_method(rb_cWindow, "stretch=", rb_window_m_set_stretch, 1);
#endif
  rb_define_method(rb_cWindow, "cursor_rect", rb_window_m_cursor_rect, 0);
  rb_define_method(rb_cWindow, "cursor_rect=", rb_window_m_set_cursor_rect, 1);
  rb_define_method(rb_cWindow, "viewport", rb_window_m_viewport, 0);
#if RGSS >= 2
  rb_define_method(rb_cWindow, "viewport=", rb_window_m_set_viewport, 1);
#endif
  rb_define_method(rb_cWindow, "active", rb_window_m_active, 0);
  rb_define_method(rb_cWindow, "active=", rb_window_m_set_active, 1);
  rb_define_method(rb_cWindow, "visible", rb_window_m_visible, 0);
  rb_define_method(rb_cWindow, "visible=", rb_window_m_set_visible, 1);
#if RGSS == 3
  rb_define_method(rb_cWindow, "arrows_visible",
      rb_window_m_arrows_visible, 0);
  rb_define_method(rb_cWindow, "arrows_visible=",
      rb_window_m_set_arrows_visible, 1);
#endif
  rb_define_method(rb_cWindow, "pause", rb_window_m_pause, 0);
  rb_define_method(rb_cWindow, "pause=", rb_window_m_set_pause, 1);
  rb_define_method(rb_cWindow, "x", rb_window_m_x, 0);
  rb_define_method(rb_cWindow, "x=", rb_window_m_set_x, 1);
  rb_define_method(rb_cWindow, "y", rb_window_m_y, 0);
  rb_define_method(rb_cWindow, "y=", rb_window_m_set_y, 1);
  rb_define_method(rb_cWindow, "width", rb_window_m_width, 0);
  rb_define_method(rb_cWindow, "width=", rb_window_m_set_width, 1);
  rb_define_method(rb_cWindow, "height", rb_window_m_height, 0);
  rb_define_method(rb_cWindow, "height=", rb_window_m_set_height, 1);
  rb_define_method(rb_cWindow, "z", rb_window_m_z, 0);
  rb_define_method(rb_cWindow, "z=", rb_window_m_set_z, 1);
  rb_define_method(rb_cWindow, "ox", rb_window_m_ox, 0);
  rb_define_method(rb_cWindow, "ox=", rb_window_m_set_ox, 1);
  rb_define_method(rb_cWindow, "oy", rb_window_m_oy, 0);
  rb_define_method(rb_cWindow, "oy=", rb_window_m_set_oy, 1);
#if RGSS == 3
  rb_define_method(rb_cWindow, "padding", rb_window_m_padding, 0);
  rb_define_method(rb_cWindow, "padding=", rb_window_m_set_padding, 1);
  rb_define_method(rb_cWindow, "padding_bottom",
      rb_window_m_padding_bottom, 0);
  rb_define_method(rb_cWindow, "padding_bottom=",
      rb_window_m_set_padding_bottom, 1);
#endif
  rb_define_method(rb_cWindow, "opacity", rb_window_m_opacity, 0);
  rb_define_method(rb_cWindow, "opacity=", rb_window_m_set_opacity, 1);
  rb_define_method(rb_cWindow, "back_opacity", rb_window_m_back_opacity, 0);
  rb_define_method(rb_cWindow, "back_opacity=",
      rb_window_m_set_back_opacity, 1);
  rb_define_method(rb_cWindow, "contents_opacity",
      rb_window_m_contents_opacity, 0);
  rb_define_method(rb_cWindow, "contents_opacity=",
      rb_window_m_set_contents_opacity, 1);
#if RGSS >= 2
  rb_define_method(rb_cWindow, "openness", rb_window_m_openness, 0);
  rb_define_method(rb_cWindow, "openness=", rb_window_m_set_openness, 1);
#endif
#if RGSS == 3
  rb_define_method(rb_cWindow, "tone", rb_window_m_tone, 0);
  rb_define_method(rb_cWindow, "tone=", rb_window_m_set_tone, 1);
#endif
}

bool rb_window_data_p(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))window_mark;
}

const struct Window *rb_window_data(VALUE obj) {
  Check_Type(obj, T_DATA);
  // Note: original RGSS doesn't check types.
  if(RDATA(obj)->dmark != (void(*)(void*))window_mark) {
    rb_raise(rb_eTypeError,
        "can't convert %s into Window",
        rb_class2name(rb_obj_class(obj)));
  }
  struct Window *ret;
  Data_Get_Struct(obj, struct Window, ret);
  return ret;
}

struct Window *rb_window_data_mut(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Window");
  return (struct Window *)rb_window_data(obj);
}

static void window_mark(struct Window *ptr) {
  rb_gc_mark(ptr->viewport);
  rb_gc_mark(ptr->windowskin);
  rb_gc_mark(ptr->contents);
  rb_gc_mark(ptr->cursor_rect);
#if RGSS == 3
  rb_gc_mark(ptr->tone);
#endif
}

static void window_free(struct Window *ptr) {
  disposeRenderable(&ptr->renderable);
  xfree(ptr);
}

static VALUE window_alloc(VALUE klass) {
  struct Window *ptr = ALLOC(struct Window);
  ptr->renderable.clear = NULL;
  ptr->renderable.prepare = prepareRenderWindow;
  ptr->renderable.render = renderWindow;
  ptr->renderable.disposed = false;

  ptr->windowskin = Qnil;
  ptr->contents = Qnil;
#if RGSS == 1
  ptr->stretch = true;
#endif
  ptr->cursor_rect = Qnil;
  ptr->viewport = Qnil;
  ptr->active = true;
  ptr->visible = true;
#if RGSS == 3
  ptr->arrows_visible = true;
#endif
  ptr->pause = false;
  ptr->x = 0;
  ptr->y = 0;
  ptr->width = 0;
  ptr->height = 0;
  // TODO: In RGSS1, content Z and background Z differ.
#if RGSS == 3
  ptr->z = 100;
#else
  ptr->z = 0;
#endif
  ptr->ox = 0;
  ptr->oy = 0;
#if RGSS == 3
  ptr->padding = 12;
  ptr->padding_bottom = 12;
#endif
  ptr->opacity = 255;
#if RGSS == 3
  ptr->back_opacity = 192;
#else
  ptr->back_opacity = 255;
#endif
  ptr->contents_opacity = 255;
#if RGSS >= 2
  ptr->openness = 255;
#endif
#if RGSS == 3
  ptr->tone = Qnil;
#endif
  ptr->cursor_tick = 0;
  ptr->pause_tick = 0;

  VALUE ret = Data_Wrap_Struct(klass, window_mark, window_free, ptr);
  ptr->contents = rb_bitmap_new(1, 1);
  ptr->cursor_rect = rb_rect_new2();
#if RGSS == 3
  ptr->tone = rb_tone_new2();
#endif
  registerRenderable(&ptr->renderable);
  return ret;
}

/*
 * call-seq:
 *   Window.new
 *   Window.new(x)
 *   Window.new(x, y)
 *   Window.new(x, y, width)
 *   Window.new(x, y, width, height)
 *
 * Creates a new window.
 */
static VALUE rb_window_m_initialize(int argc, VALUE *argv, VALUE self) {
  struct Window *ptr = rb_window_data_mut(self);
  if(argc > 4) {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 4)", argc);
  }
  ptr->x = argc > 0 ? NUM2INT(argv[0]) : 0;
  ptr->y = argc > 1 ? NUM2INT(argv[1]) : 0;
  ptr->width = argc > 2 ? NUM2INT(argv[2]) : 0;
  ptr->height = argc > 3 ? NUM2INT(argv[3]) : 0;
  return Qnil;
}

static VALUE rb_window_m_initialize_copy(VALUE self, VALUE orig) {
  struct Window *ptr = rb_window_data_mut(self);
  const struct Window *orig_ptr = rb_window_data(orig);
  ptr->windowskin = orig_ptr->windowskin;
  ptr->contents = orig_ptr->contents;
#if RGSS == 1
  ptr->stretch = orig_ptr->stretch;
#endif
  rb_rect_set2(ptr->cursor_rect, orig_ptr->cursor_rect);
  ptr->viewport = orig_ptr->viewport;
  ptr->active = orig_ptr->active;
  ptr->visible = orig_ptr->visible;
#if RGSS == 3
  ptr->arrows_visible = orig_ptr->arrows_visible;
#endif
  ptr->pause = orig_ptr->pause;
  ptr->x = orig_ptr->x;
  ptr->y = orig_ptr->y;
  ptr->width = orig_ptr->width;
  ptr->height = orig_ptr->height;
  ptr->z = orig_ptr->z;
  ptr->ox = orig_ptr->ox;
  ptr->oy = orig_ptr->oy;
#if RGSS == 3
  ptr->padding = orig_ptr->padding;
  ptr->padding_bottom = orig_ptr->padding_bottom;
#endif
  ptr->opacity = orig_ptr->opacity;
  ptr->back_opacity = orig_ptr->back_opacity;
  ptr->contents_opacity = orig_ptr->contents_opacity;
#if RGSS >= 2
  ptr->openness = orig_ptr->openness;
#endif
#if RGSS == 3
  ptr->tone = orig_ptr->tone;
#endif
  ptr->cursor_tick = orig_ptr->cursor_tick;
  ptr->pause_tick = orig_ptr->pause_tick;
  return Qnil;
}

static VALUE rb_window_m_dispose(VALUE self) {
  struct Window *ptr = rb_window_data_mut(self);
  disposeRenderable(&ptr->renderable);
  return Qnil;
}

static VALUE rb_window_m_disposed_p(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->renderable.disposed ? Qtrue : Qfalse;
}

static VALUE rb_window_m_update(VALUE self) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->cursor_tick = (ptr->cursor_tick + 1) % 40;
  if(ptr->pause) {
    ++ptr->pause_tick;
    if(ptr->pause_tick >= 64 + 16) ptr->pause_tick -= 64;
  }
  return Qnil;
}

#if RGSS == 3
static VALUE rb_window_m_move(
    VALUE self, VALUE x, VALUE y, VALUE width, VALUE height) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->x = NUM2INT(x);
  ptr->y = NUM2INT(y);
  ptr->width = NUM2INT(width);
  ptr->height = NUM2INT(height);
  return Qnil;
}

static VALUE rb_window_m_open_p(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->openness == 255 ? Qtrue : Qfalse;
}

static VALUE rb_window_m_close_p(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->openness == 0 ? Qtrue : Qfalse;
}
#endif

static VALUE rb_window_m_windowskin(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->windowskin;
}

static VALUE rb_window_m_set_windowskin(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  if(newval != Qnil) rb_bitmap_data(newval);
  ptr->windowskin = newval;
  return newval;
}

static VALUE rb_window_m_contents(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->contents;
}

static VALUE rb_window_m_set_contents(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  if(newval != Qnil) rb_bitmap_data(newval);
  ptr->contents = newval;
  return newval;
}

#if RGSS == 1
static VALUE rb_window_m_stretch(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->stretch ? Qtrue : Qfalse;
}

static VALUE rb_window_m_set_stretch(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->stretch = RTEST(newval);
  return newval;
}
#endif

static VALUE rb_window_m_cursor_rect(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->cursor_rect;
}

static VALUE rb_window_m_set_cursor_rect(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  rb_rect_set2(ptr->cursor_rect, newval);
  return newval;
}

static VALUE rb_window_m_viewport(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->viewport;
}

#if RGSS >= 2
static VALUE rb_window_m_set_viewport(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  if(newval != Qnil) rb_viewport_data(newval);
  ptr->viewport = newval;
  return newval;
}
#endif

static VALUE rb_window_m_active(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->active ? Qtrue : Qfalse;
}

static VALUE rb_window_m_set_active(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->active = RTEST(newval);
  return newval;
}

static VALUE rb_window_m_visible(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->visible ? Qtrue : Qfalse;
}

static VALUE rb_window_m_set_visible(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->visible = RTEST(newval);
  return newval;
}

#if RGSS == 3
static VALUE rb_window_m_arrows_visible(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->arrows_visible ? Qtrue : Qfalse;
}

static VALUE rb_window_m_set_arrows_visible(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->arrows_visible = RTEST(newval);
  return newval;
}
#endif

static VALUE rb_window_m_pause(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->pause ? Qtrue : Qfalse;
}

static VALUE rb_window_m_set_pause(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->pause = RTEST(newval);
  if(!ptr->pause) ptr->pause_tick = 0;
  return newval;
}

static VALUE rb_window_m_x(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->x);
}

static VALUE rb_window_m_set_x(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->x = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_y(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->y);
}

static VALUE rb_window_m_set_y(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->y = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_width(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->width);
}

static VALUE rb_window_m_set_width(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->width = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_height(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->height);
}

static VALUE rb_window_m_set_height(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->height = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_z(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->z);
}

static VALUE rb_window_m_set_z(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->z = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_ox(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->ox);
}

static VALUE rb_window_m_set_ox(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->ox = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_oy(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->oy);
}

static VALUE rb_window_m_set_oy(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->oy = NUM2INT(newval);
  return newval;
}

#if RGSS == 3
static VALUE rb_window_m_padding(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->padding);
}

static VALUE rb_window_m_set_padding(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->padding_bottom = ptr->padding = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_padding_bottom(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->padding_bottom);
}

static VALUE rb_window_m_set_padding_bottom(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->padding_bottom = NUM2INT(newval);
  return newval;
}
#endif

static VALUE rb_window_m_opacity(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->opacity);
}

static VALUE rb_window_m_set_opacity(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->opacity = saturateInt32(NUM2INT(newval), 0, 255);
  return newval;
}

static VALUE rb_window_m_back_opacity(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->back_opacity);
}

static VALUE rb_window_m_set_back_opacity(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->back_opacity = saturateInt32(NUM2INT(newval), 0, 255);
  return newval;
}

static VALUE rb_window_m_contents_opacity(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->contents_opacity);
}

static VALUE rb_window_m_set_contents_opacity(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->contents_opacity = saturateInt32(NUM2INT(newval), 0, 255);
  return newval;
}

#if RGSS >= 2
static VALUE rb_window_m_openness(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return INT2NUM(ptr->openness);
}

static VALUE rb_window_m_set_openness(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  ptr->openness = saturateInt32(NUM2INT(newval), 0, 255);
  return newval;
}
#endif

#if RGSS == 3
static VALUE rb_window_m_tone(VALUE self) {
  const struct Window *ptr = rb_window_data(self);
  return ptr->tone;
}

static VALUE rb_window_m_set_tone(VALUE self, VALUE newval) {
  struct Window *ptr = rb_window_data_mut(self);
  rb_tone_set2(ptr->tone, newval);
  return newval;
}
#endif

static void prepareRenderWindow(struct Renderable *renderable, int t) {
  struct Window *ptr = (struct Window *)renderable;
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
#if RGSS == 1
  job.z = ptr->z + 2;
  job.aux[0] = 1;
  queueRenderJob(ptr->viewport, job);
#endif
}

static void renderWindow(
    struct Renderable *renderable, const struct RenderJob *job,
    const struct RenderViewport *viewport) {
#if RGSS >= 2
  int content_job_no = 0;
#else
  int content_job_no = 1;
#endif
  struct Window *ptr = (struct Window *)renderable;
#if RGSS >= 2
  int openness = ptr->openness;
#else
  int openness = 255;
#endif
  if(openness == 0) return;

  int open_height = ptr->height * openness / 255;
  int open_y = ptr->y + (ptr->height - open_height) / 2;

#if RGSS == 3
  int padding = ptr->padding;
  int padding_bottom = ptr->padding_bottom;
#else
  // TODO: is the padding correct?
  int padding = 16;
  int padding_bottom = 16;
#endif

#if RGSS == 3
  bool arrows_visible = ptr->arrows_visible;
#else
  bool arrows_visible = true;
#endif

  const struct Bitmap *skin_bitmap_ptr = NULL;
  SDL_Surface *skin_surface = NULL;
  if(ptr->windowskin != Qnil) {
    skin_bitmap_ptr = rb_bitmap_data(ptr->windowskin);
    skin_surface = skin_bitmap_ptr->surface;
  }

  const struct Bitmap *contents_bitmap_ptr = NULL;
  SDL_Surface *contents_surface = NULL;
  if(ptr->windowskin != Qnil) {
    contents_bitmap_ptr = rb_bitmap_data(ptr->contents);
    contents_surface = contents_bitmap_ptr->surface;
  }

  glEnable(GL_BLEND);
  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
  glBlendEquation(GL_FUNC_ADD);

  if(skin_surface && job->aux[0] == 0) {
#if RGSS == 3
    const struct Tone *tone_ptr = rb_tone_data(ptr->tone);
#endif

    glActiveTexture(GL_TEXTURE0);
    bitmapBindTexture((struct Bitmap *)skin_bitmap_ptr);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

#if RGSS >= 2
    bool use_stretched_background = true;
    bool use_tiled_background = true;
#else
    bool use_stretched_background = ptr->stretch;
    bool use_tiled_background = !ptr->stretch;
#endif

    if(use_stretched_background) {
      glUseProgram(shader1);
      glUniform1i(glGetUniformLocation(shader1, "windowskin"), 0);
      glUniform2f(glGetUniformLocation(shader1, "resolution"),
          viewport->width, viewport->height);
      glUniform1f(glGetUniformLocation(shader1, "opacity"),
          ptr->opacity * ptr->back_opacity / (255.0 * 255.0));
#if RGSS == 3
      glUniform4f(glGetUniformLocation(shader1, "window_tone"),
          tone_ptr->red / 255.0,
          tone_ptr->green / 255.0,
          tone_ptr->blue / 255.0,
          tone_ptr->gray / 255.0);
#else
      glUniform4f(glGetUniformLocation(shader1, "window_tone"),
          0.0, 0.0, 0.0, 0.0);
#endif

      gl_draw_rect(
          -viewport->ox + ptr->x + 2,
          -viewport->oy + open_y + 2,
          -viewport->ox + ptr->x + ptr->width - 2,
          -viewport->oy + open_y + open_height - 2,
          0.0, 0.0, 1.0, 1.0);
    }

    if(use_tiled_background) {
      glUseProgram(shader2);
      glUniform1i(glGetUniformLocation(shader2, "windowskin"), 0);
      glUniform2f(glGetUniformLocation(shader2, "resolution"),
          viewport->width, viewport->height);
      glUniform1f(glGetUniformLocation(shader2, "opacity"),
          ptr->opacity * ptr->back_opacity / (255.0 * 255.0));
#if RGSS == 3
      glUniform4f(glGetUniformLocation(shader2, "window_tone"),
          tone_ptr->red / 255.0,
          tone_ptr->green / 255.0,
          tone_ptr->blue / 255.0,
          tone_ptr->gray / 255.0);
#else
      glUniform4f(glGetUniformLocation(shader2, "window_tone"),
          0.0, 0.0, 0.0, 0.0);
#endif

      gl_draw_rect(
          -viewport->ox + ptr->x + 2,
          -viewport->oy + open_y + 2,
          -viewport->ox + ptr->x + ptr->width - 2,
          -viewport->oy + open_y + open_height - 2,
          0.0, 0.0, (ptr->width - 4) / 64.0, (open_height - 4) / 64.0);
    }

    glUseProgram(shader3);
    glUniform1i(glGetUniformLocation(shader3, "windowskin"), 0);
    glUniform2f(glGetUniformLocation(shader3, "resolution"),
        viewport->width, viewport->height);
    glUniform1f(glGetUniformLocation(shader3, "opacity"),
        ptr->opacity / 255.0);
    glUniform2f(glGetUniformLocation(shader3, "bg_size"),
        ptr->width, open_height);

    gl_draw_rect(
        -viewport->ox + ptr->x,
        -viewport->oy + open_y,
        -viewport->ox + ptr->x + ptr->width,
        -viewport->oy + open_y + open_height,
        0.0, 0.0, ptr->width, open_height);

    glUseProgram(shader4);
    glUniform1i(glGetUniformLocation(shader4, "contents"), 0);
    glUniform2f(glGetUniformLocation(shader4, "resolution"),
        viewport->width, viewport->height);
    glUniform1f(glGetUniformLocation(shader4, "opacity"),
        ptr->opacity / 255.0);

    if(openness == 255 && contents_bitmap_ptr != NULL && arrows_visible) {
#if RGSS >= 2
      double src_center_x = 64 + 32;
      double src_center_y = 32;
      double src_width = 128;
      double src_height = 128;
#else
      double src_center_x = 128 + 32;
      double src_center_y = 32;
      double src_width = 192;
      double src_height = 128;
#endif
      if(ptr->ox > 0) {
        gl_draw_rect(
            -viewport->ox + ptr->x + 4,
            -viewport->oy + ptr->y + ptr->height * 0.5 - 8,
            -viewport->ox + ptr->x + 12,
            -viewport->oy + ptr->y + ptr->height * 0.5 + 8,
            (src_center_x - 16) / src_width,
            (src_center_y - 8) / src_height,
            (src_center_x - 8) / src_width,
            (src_center_y + 8) / src_height);
      }
      if(ptr->oy > 0) {
        gl_draw_rect(
            -viewport->ox + ptr->x + ptr->width * 0.5 - 8,
            -viewport->oy + ptr->y + 4,
            -viewport->ox + ptr->x + ptr->width * 0.5 + 8,
            -viewport->oy + ptr->y + 12,
            (src_center_x - 8) / src_width,
            (src_center_y - 16) / src_height,
            (src_center_x + 8) / src_width,
            (src_center_y - 8) / src_height);
      }
      if(contents_surface->w - ptr->ox > ptr->width - padding * 2) {
        gl_draw_rect(
            -viewport->ox + ptr->x + ptr->width - 12,
            -viewport->oy + ptr->y + ptr->height * 0.5 - 8,
            -viewport->ox + ptr->x + ptr->width - 4,
            -viewport->oy + ptr->y + ptr->height * 0.5 + 8,
            (src_center_x + 8) / src_width,
            (src_center_y - 8) / src_height,
            (src_center_x + 16) / src_width,
            (src_center_y + 8) / src_height);
      }
      if(contents_surface->h - ptr->oy > ptr->height - padding - padding_bottom) {
        gl_draw_rect(
            -viewport->ox + ptr->x + ptr->width * 0.5 - 8,
            -viewport->oy + ptr->y + ptr->height - 12,
            -viewport->ox + ptr->x + ptr->width * 0.5 + 8,
            -viewport->oy + ptr->y + ptr->height - 4,
            (src_center_x - 8) / src_width,
            (src_center_y + 8) / src_height,
            (src_center_x + 8) / src_width,
            (src_center_y + 16) / src_height);
      }
    }

    if(openness == 255 && ptr->pause) {
#if RGSS >= 2
      double src_x = 64 + 32;
      double src_y = 64;
      double src_width = 128;
      double src_height = 128;
#else
      double src_x = 128 + 32;
      double src_y = 64;
      double src_width = 192;
      double src_height = 128;
#endif

      int pause_opacity = ptr->pause_tick > 16 ? 16 : ptr->pause_tick;
      glUniform1f(glGetUniformLocation(shader4, "opacity"),
          ptr->opacity * pause_opacity / (255.0 * 16.0));

      int pause_anim = ptr->pause_tick % 64 / 16;
      double src_x2 = pause_anim % 2 * 16;
      double src_y2 = pause_anim / 2 * 16;

      gl_draw_rect(
          -viewport->ox + ptr->x + ptr->width * 0.5 - 8,
          -viewport->oy + ptr->y + ptr->height - 16,
          -viewport->ox + ptr->x + ptr->width * 0.5 + 8,
          -viewport->oy + ptr->y + ptr->height,
          (src_x + src_x2) / src_width,
          (src_y + src_y2) / src_height,
          (src_x + src_x2 + 16) / src_width,
          (src_y + src_y2 + 16) / src_height);
    }
  }

  const struct Rect *cursor_rect_ptr = rb_rect_data(ptr->cursor_rect);

  if(skin_surface && openness == 255 &&
      job->aux[0] == content_job_no &&
      cursor_rect_ptr->width > 0 && cursor_rect_ptr->height > 0) {
    glActiveTexture(GL_TEXTURE0);
    bitmapBindTexture((struct Bitmap *)skin_bitmap_ptr);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    // TODO: clipping?
#if RGSS == 3
    int adjusted_x = ptr->x + cursor_rect_ptr->x + padding - ptr->ox;
    int adjusted_y = ptr->y + cursor_rect_ptr->y + padding - ptr->oy;
#else
    int adjusted_x = ptr->x + cursor_rect_ptr->x + padding;
    int adjusted_y = ptr->y + cursor_rect_ptr->y + padding;
#endif

    int cursor_opacity = 128;
    if(ptr->active) {
      cursor_opacity = 255 - (20 - abs(ptr->cursor_tick - 20)) * 8;
    }

    glUseProgram(cursor_shader);
    glUniform1i(glGetUniformLocation(cursor_shader, "windowskin"), 0);
    glUniform2f(glGetUniformLocation(cursor_shader, "resolution"),
        viewport->width, viewport->height);
    glUniform1f(glGetUniformLocation(cursor_shader, "opacity"),
        ptr->contents_opacity * cursor_opacity / (255.0 * 255.0));
    glUniform2f(glGetUniformLocation(cursor_shader, "cursor_size"),
        cursor_rect_ptr->width, cursor_rect_ptr->height);

    gl_draw_rect(
        -viewport->ox + adjusted_x,
        -viewport->oy + adjusted_y,
        -viewport->ox + adjusted_x + cursor_rect_ptr->width,
        -viewport->oy + adjusted_y + cursor_rect_ptr->height,
        0.0, 0.0, cursor_rect_ptr->width, cursor_rect_ptr->height);
  }

  if(contents_surface && openness == 255 &&
      job->aux[0] == content_job_no) {
    int wcontent_width = ptr->width - padding * 2;
    int wcontent_height = ptr->height - padding - padding_bottom;
    int content_width = contents_surface->w;
    int content_height = contents_surface->h;
    int clip_left = ptr->ox;
    if(clip_left < 0) clip_left = 0;
    int clip_top = ptr->oy;
    if(clip_top < 0) clip_top = 0;
    int clip_right = ptr->ox + wcontent_width;
    if(clip_right > content_width) clip_right = content_width;
    int clip_bottom = ptr->oy + wcontent_height;
    if(clip_bottom > content_height) clip_bottom = content_height;

    glUseProgram(shader4);
    glUniform1i(glGetUniformLocation(shader4, "contents"), 0);
    glUniform2f(glGetUniformLocation(shader4, "resolution"),
        viewport->width, viewport->height);
    glUniform1f(glGetUniformLocation(shader4, "opacity"),
        ptr->contents_opacity / 255.0);

    glActiveTexture(GL_TEXTURE0);
    bitmapBindTexture((struct Bitmap *)contents_bitmap_ptr);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    gl_draw_rect(
        -viewport->ox + ptr->x + padding + (clip_left - ptr->ox),
        -viewport->oy + ptr->y + padding + (clip_top - ptr->oy),
        -viewport->ox + ptr->x + padding + (clip_right - ptr->ox),
        -viewport->oy + ptr->y + padding + (clip_bottom - ptr->oy),
        (double)clip_left / content_width,
        (double)clip_top / content_height,
        (double)clip_right / content_width,
        (double)clip_bottom / content_height);
  }

  glUseProgram(0);
}

void initWindowSDL() {
  static const char *vsh1_source =
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

  static const char *fsh1_source =
    "#version 120\n"
    "#if __VERSION__ >= 130\n"
    "#define texture2D texture\n"
    "#define texture2DProj textureProj\n"
    "#endif\n"
    "\n"
    "uniform sampler2D windowskin;\n"
    "uniform float opacity;\n"
    "uniform vec4 window_tone;\n"
    "\n"
    "void main(void) {\n"
#if RGSS >= 2
    "    vec4 color = texture2D(windowskin, vec2(gl_TexCoord[0].x * 0.5, gl_TexCoord[0].y * 0.5));\n"
#else
    "    vec4 color = texture2D(windowskin, vec2(gl_TexCoord[0].x * (2.0 / 3.0), gl_TexCoord[0].y));\n"
#endif
    "    /* Grayscale */\n"
    "    float gray = color.r * 0.298912 + color.g * 0.586611 + color.b * 0.114478;\n"
    "    color.rgb *= 1.0 - window_tone.a;\n"
    "    color.rgb += vec3(gray, gray, gray) * window_tone.a;\n"
    "    /* tone blending */\n"
    "    color.rgb = min(max(color.rgb + window_tone.rgb, 0.0), 1.0);\n"
    "    color.a *= opacity;\n"
    "    gl_FragColor = color;\n"
    "    /* premultiplication */\n"
    "    gl_FragColor.rgb *= gl_FragColor.a;\n"
    "}\n";

  shader1 = compileShaders(vsh1_source, fsh1_source);

  static const char *vsh2_source =
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

  static const char *fsh2_source =
    "#version 120\n"
    "#if __VERSION__ >= 130\n"
    "#define texture2D texture\n"
    "#define texture2DProj textureProj\n"
    "#endif\n"
    "\n"
    "uniform sampler2D windowskin;\n"
    "uniform float opacity;\n"
    "uniform vec4 window_tone;\n"
    "\n"
    "void main(void) {\n"
    "    vec2 coord = mod(gl_TexCoord[0].xy, 1.0);\n"
#if RGSS >= 2
    "    vec4 color = texture2D(windowskin, vec2(coord.x * 0.5, coord.y * 0.5 + 0.5));\n"
#else
    "    vec4 color = texture2D(windowskin, vec2(coord.x * (2.0 / 3.0), coord.y));\n"
#endif
    "    /* Grayscale */\n"
    "    float gray = color.r * 0.298912 + color.g * 0.586611 + color.b * 0.114478;\n"
    "    color.rgb *= 1.0 - window_tone.a;\n"
    "    color.rgb += vec3(gray, gray, gray) * window_tone.a;\n"
    "    /* tone blending */\n"
    "    color.rgb = min(max(color.rgb + window_tone.rgb, 0.0), 1.0);\n"
    "    color.a *= opacity;\n"
    "    gl_FragColor = color;\n"
    "    /* premultiplication */\n"
    "    gl_FragColor.rgb *= gl_FragColor.a;\n"
    "}\n";

  shader2 = compileShaders(vsh2_source, fsh2_source);

  static const char *vsh3_source =
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

  static const char *fsh3_source =
    "#version 120\n"
    "#if __VERSION__ >= 130\n"
    "#define texture2D texture\n"
    "#define texture2DProj textureProj\n"
    "#endif\n"
    "\n"
    "uniform sampler2D windowskin;\n"
    "uniform float opacity;\n"
    "uniform vec2 bg_size;\n"
    "\n"
    "void main(void) {\n"
    "    vec2 coord = gl_TexCoord[0].xy;\n"
    "    vec2 reverse_coord = bg_size - coord;\n"
    "    vec2 src_coord;\n"
    "    bool draw = false;\n"
    "    if(coord.x < 16.0) {\n"
    "      src_coord.x = coord.x;\n"
    "      draw = true;\n"
    "    } else if(reverse_coord.x < 16.0) {\n"
    "      src_coord.x = 64.0 - reverse_coord.x;\n"
    "      draw = true;\n"
    "    } else {\n"
    "      src_coord.x = mod(coord.x - 16.0, 32.0) + 16.0;\n"
    "    }\n"
    "    if(coord.y < 16.0) {\n"
    "      src_coord.y = coord.y;\n"
    "      draw = true;\n"
    "    } else if(reverse_coord.y < 16.0) {\n"
    "      src_coord.y = 64.0 - reverse_coord.y;\n"
    "      draw = true;\n"
    "    } else {\n"
    "      src_coord.y = mod(coord.y - 16.0, 32.0) + 16.0;\n"
    "    }\n"
#if RGSS >= 2
    "    src_coord.x = (src_coord.x + 64.0) / 128.0;\n"
    "    src_coord.y = src_coord.y / 128.0;\n"
#else
    "    src_coord.x = (src_coord.x + 128.0) / 192.0;\n"
    "    src_coord.y = src_coord.y / 128.0;\n"
#endif
    "    if(draw) {\n"
    "      gl_FragColor = texture2D(windowskin, src_coord);\n"
    "    } else {\n"
    "      gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);\n"
    "    }\n"
    "    gl_FragColor.a *= opacity;\n"
    "    /* premultiplication */\n"
    "    gl_FragColor.rgb *= gl_FragColor.a;\n"
    "}\n";

  shader3 = compileShaders(vsh3_source, fsh3_source);

  static const char *vsh4_source =
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

  static const char *fsh4_source =
    "#version 120\n"
    "#if __VERSION__ >= 130\n"
    "#define texture2D texture\n"
    "#define texture2DProj textureProj\n"
    "#endif\n"
    "\n"
    "uniform sampler2D windowskin;\n"
    "uniform float opacity;\n"
    "\n"
    "void main(void) {\n"
    "    vec4 color = texture2D(windowskin, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y));\n"
    "    color.a *= opacity;\n"
    "    gl_FragColor = color;\n"
    "    /* premultiplication */\n"
    "    gl_FragColor.rgb *= gl_FragColor.a;\n"
    "}\n";

  shader4 = compileShaders(vsh4_source, fsh4_source);

  static const char *cursor_vsh_source =
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

  static const char *cursor_fsh_source =
    "#version 120\n"
    "#if __VERSION__ >= 130\n"
    "#define texture2D texture\n"
    "#define texture2DProj textureProj\n"
    "#endif\n"
    "\n"
    "uniform sampler2D windowskin;\n"
    "uniform float opacity;\n"
    "uniform vec2 cursor_size;\n"
    "\n"
    "void main(void) {\n"
    "    vec2 coord = gl_TexCoord[0].xy;\n"
    "    vec2 reverse_coord = cursor_size - coord;\n"
    "    vec2 src_coord;\n"
    "    if(coord.x < 2.0) {\n"
    "      src_coord.x = coord.x;\n"
    "    } else if(reverse_coord.x < 2.0) {\n"
    "      src_coord.x = 32.0 - reverse_coord.x;\n"
    "    } else {\n"
    "      src_coord.x = (coord.x - 2.0) / (cursor_size.x - 4.0) * 28.0 + 2.0;\n"
    "    }\n"
    "    if(coord.y < 2.0) {\n"
    "      src_coord.y = coord.y;\n"
    "    } else if(reverse_coord.y < 2.0) {\n"
    "      src_coord.y = 32.0 - reverse_coord.y;\n"
    "    } else {\n"
    "      src_coord.y = (coord.y - 2.0) / (cursor_size.y - 4.0) * 28.0 + 2.0;\n"
    "    }\n"
#if RGSS >= 2
    "    src_coord.x = (src_coord.x + 64.0) / 128.0;\n"
    "    src_coord.y = (src_coord.y + 64.0) / 128.0;\n"
#else
    "    src_coord.x = (src_coord.x + 128.0) / 192.0;\n"
    "    src_coord.y = (src_coord.y + 64.0) / 128.0;\n"
#endif
    "    gl_FragColor = texture2D(windowskin, src_coord);\n"
    "    gl_FragColor.a *= opacity;\n"
    "    /* premultiplication */\n"
    "    gl_FragColor.rgb *= gl_FragColor.a;\n"
    "}\n";

  cursor_shader = compileShaders(cursor_vsh_source, cursor_fsh_source);

}

void deinitWindowSDL() {
  if(cursor_shader) glDeleteProgram(cursor_shader);
  if(shader4) glDeleteProgram(shader4);
  if(shader3) glDeleteProgram(shader3);
  if(shader2) glDeleteProgram(shader2);
  if(shader1) glDeleteProgram(shader1);
}
