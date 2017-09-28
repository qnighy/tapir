#include <stdio.h>
#include <stdlib.h>
#include "Win32APIFake.h"

VALUE rb_cWin32APIFake;

static void lookup_trgssx(VALUE self, const char *func);
static void lookup_gdi32(VALUE self, const char *func);

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
  } else {
    fprintf(stderr, "unimplemented: %s.dll: %s\n", dllname, func);
  }
  return Qnil;
}

static void lookup_trgssx(VALUE self, const char *func) {
  (void) self;
  fprintf(stderr, "unimplemented: TRGSSX.dll: %s\n", func);
}
static void lookup_gdi32(VALUE self, const char *func) {
  (void) self;
  fprintf(stderr, "unimplemented: gdi32.dll: %s\n", func);
}
