// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "Win32APIFake.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "misc.h"

struct Win32Rect {
  int32_t left, top, right, bottom;
};

VALUE rb_cWin32APIFake;

static void define_fake(VALUE obj, VALUE (*func)(), int argc);

static void lookup_trgssx(VALUE self, const char *func);
static void lookup_gdi32(VALUE self, const char *func);
static void lookup_user32(VALUE self, const char *func);

static VALUE rb_win32apifake_m_initialize(int argc, VALUE *argv, VALUE self);

void Init_Win32APIFake() {
  rb_cWin32APIFake = rb_define_class("Win32API", rb_cObject);
  rb_define_private_method(rb_cWin32APIFake, "initialize",
      rb_win32apifake_m_initialize, -1);
}

static VALUE rb_win32apifake_m_initialize(int argc, VALUE *argv, VALUE self) {
  if(argc != 3 && argc != 4) {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 3..4)", argc);
  }
  const char *dllname = StringValueCStr(argv[0]);
  const char *func = StringValueCStr(argv[1]);
  if(!strcmp(dllname, "TRGSSX")) {
    lookup_trgssx(self, func);
  } else if(!strcmp(dllname, "gdi32")) {
    lookup_gdi32(self, func);
  } else if(!strcmp(dllname, "user32")) {
    lookup_user32(self, func);
  } else {
    fprintf(stderr, "unimplemented: %s.dll: %s\n", dllname, func);
  }
  return Qnil;
}

static void define_fake(VALUE obj, VALUE (*func)(), int argc) {
  rb_define_singleton_method(obj, "call", func, argc);
  rb_define_singleton_method(obj, "Call", func, argc);
}

static VALUE rb_FindWindow(VALUE self, VALUE class_name, VALUE window_name);
static VALUE rb_GetDesktopWindow(VALUE self);
static VALUE rb_GetWindowLong(VALUE self, VALUE hwnd, VALUE index);
static VALUE rb_SystemParametersInfo(
    VALUE self, VALUE action, VALUE param, VALUE pparam, VALUE update_option);

static void lookup_trgssx(VALUE self, const char *func) {
  (void) self;
  fprintf(stderr, "unimplemented: TRGSSX.dll: %s\n", func);
}

static void lookup_gdi32(VALUE self, const char *func) {
  (void) self;
  fprintf(stderr, "unimplemented: gdi32.dll: %s\n", func);
}

static void lookup_user32(VALUE self, const char *func) {
  (void) self;
  if(!strcmp(func, "FindWindow")) {
    define_fake(self, rb_FindWindow, 2);
  } else if(!strcmp(func, "GetDesktopWindow")) {
    define_fake(self, rb_GetDesktopWindow, 0);
  } else if(!strcmp(func, "GetWindowLong")) {
    define_fake(self, rb_GetWindowLong, 2);
  } else if(!strcmp(func, "SystemParametersInfo")) {
    define_fake(self, rb_SystemParametersInfo, 4);
  } else {
    fprintf(stderr, "unimplemented: user32.dll: %s\n", func);
  }
}

static VALUE rb_FindWindow(VALUE self, VALUE class_name, VALUE window_name) {
  (void) self;
  (void) class_name;
  (void) window_name;
  return INT2NUM(1234);
}

static VALUE rb_GetDesktopWindow(VALUE self) {
  (void) self;
  return INT2NUM(4567);
}

static VALUE rb_GetWindowLong(VALUE self, VALUE hwnd, VALUE index) {
  (void) self;
  (void) hwnd;
  (void) index;
  return INT2NUM(3456);
}

static VALUE rb_SystemParametersInfo(
    VALUE self, VALUE action, VALUE param, VALUE pparam, VALUE update_option) {
  (void) self;
  int action_i = NUM2INT(action);
  if(action_i == 0x30) {
    (void) param;
    (void) update_option;
    char *p = StringValuePtr(pparam);
    if(RSTRING_LEN(p) < (int)sizeof(struct Win32Rect)) return INT2NUM(-1);
    struct Win32Rect rect = { 0, 0, 1280, 1024 };
    memcpy(p, &rect, sizeof(rect));
    return INT2NUM(0);
  }
  return INT2NUM(-1);
}
