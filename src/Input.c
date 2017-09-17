#include <stdio.h>
#include <stdlib.h>
#include "Input.h"
#include "sdl_misc.h"

VALUE rb_mInput;

#define RGSS_KEY_DOWN 2
#define RGSS_KEY_LEFT 4
#define RGSS_KEY_RIGHT 6
#define RGSS_KEY_UP 8
#define RGSS_KEY_A 11
#define RGSS_KEY_B 12
#define RGSS_KEY_C 13
#define RGSS_KEY_X 14
#define RGSS_KEY_Y 15
#define RGSS_KEY_Z 16
#define RGSS_KEY_L 17
#define RGSS_KEY_R 18
#define RGSS_KEY_SHIFT 21
#define RGSS_KEY_CTRL 22
#define RGSS_KEY_ALT 23
#define RGSS_KEY_F5 25
#define RGSS_KEY_F6 26
#define RGSS_KEY_F7 27
#define RGSS_KEY_F8 28
#define RGSS_KEY_F9 29
#define RGSS_KEY_MAX 30

static const char *keynames[RGSS_KEY_MAX] = {
  NULL, NULL, "DOWN", NULL, "LEFT", NULL, "RIGHT", NULL, "UP", NULL, NULL,
  "A", "B", "C", "X", "Y", "Z", "L", "R", NULL, NULL, "SHIFT", "CTRL", "ALT",
  NULL, "F5", "F6", "F7", "F8", "F9"
};
static ID keyname_ids[RGSS_KEY_MAX];

static int keycount[RGSS_KEY_MAX], keycount2[RGSS_KEY_MAX];

static VALUE rb_input_s_update(VALUE self);
static VALUE rb_input_s_press_p(VALUE self, VALUE key);
static VALUE rb_input_s_trigger_p(VALUE self, VALUE key);
static VALUE rb_input_s_repeat_p(VALUE self, VALUE key);
static VALUE rb_input_s_dir4(VALUE self);
static VALUE rb_input_s_dir8(VALUE self);

void Init_Input() {
  rb_mInput = rb_define_module("Input");
  rb_define_singleton_method(rb_mInput, "update", rb_input_s_update, 0);
  rb_define_singleton_method(rb_mInput, "press?", rb_input_s_press_p, 1);
  rb_define_singleton_method(rb_mInput, "trigger?", rb_input_s_trigger_p, 1);
  rb_define_singleton_method(rb_mInput, "repeat?", rb_input_s_repeat_p, 1);
  rb_define_singleton_method(rb_mInput, "dir4", rb_input_s_dir4, 0);
  rb_define_singleton_method(rb_mInput, "dir8", rb_input_s_dir8, 0);

  for(int i = 0; i < RGSS_KEY_MAX; ++i) {
    if(!keynames[i]) continue;
    keyname_ids[i] = rb_intern(keynames[i]);
#if RGSS == 3
    rb_const_set(rb_mInput, keyname_ids[i], ID2SYM(keyname_ids[i]));
#else
    rb_const_set(rb_mInput, keyname_ids[i], INT2NUM(i));
#endif
  }

  for(int i = 0; i < RGSS_KEY_MAX; ++i) {
    keycount[i] = keycount2[i] = -1;
  }
}

static VALUE rb_input_s_update(VALUE klass) {
  (void) klass;

  // TODO: also check gamepads

  for(int i = 0; i < RGSS_KEY_MAX; ++i) {
    keycount[i] = keycount2[i];
    if(keycount2[i] >= 0) {
      ++keycount2[i];
    }
  }
  return Qnil;
}

static int convertRubyKey(VALUE key) {
  for(int i = 0; i < RGSS_KEY_MAX; ++i) {
    if(!keynames[i]) continue;
    if(key == INT2NUM(i)) return i;
#if RGSS == 3
    if(key == ID2SYM(keyname_ids[i])) return i;
#endif
  }
  return -1;
}

static VALUE rb_input_s_press_p(VALUE klass, VALUE key) {
  (void) klass;
  int rkey = convertRubyKey(key);
  if(rkey != -1) {
    return keycount[rkey] >= 0 ? Qtrue : Qfalse;
  }
  // TODO: error handling
  return Qnil;
}

static VALUE rb_input_s_trigger_p(VALUE klass, VALUE key) {
  (void) klass;
  int rkey = convertRubyKey(key);
  if(rkey != -1) {
    return keycount[rkey] == 0 ? Qtrue : Qfalse;
  }
  // TODO: error handling
  return Qnil;
}

static VALUE rb_input_s_repeat_p(VALUE klass, VALUE key) {
  (void) klass;
  int rkey = convertRubyKey(key);
  if(rkey != -1) {
    return keycount[rkey] >= 24 && keycount[rkey] % 6 == 0 ? Qtrue : Qfalse;
  }
  return Qnil;
}

static VALUE rb_input_s_dir4(VALUE klass) {
  (void) klass;
  fprintf(stderr, "Input.dir4\n");
  return Qnil;
}

static VALUE rb_input_s_dir8(VALUE klass) {
  (void) klass;
  fprintf(stderr, "Input.dir8\n");
  return Qnil;
}

static int convertSDLKey(SDL_Keycode key) {
  if(key == SDLK_DOWN) return RGSS_KEY_DOWN;
  if(key == SDLK_LEFT) return RGSS_KEY_LEFT;
  if(key == SDLK_RIGHT) return RGSS_KEY_RIGHT;
  if(key == SDLK_UP) return RGSS_KEY_UP;
  if(key == SDLK_LCTRL || key == SDLK_RCTRL) return RGSS_KEY_CTRL;
  if(key == SDLK_LALT || key == SDLK_RALT) return RGSS_KEY_ALT;
  if(key == SDLK_F5) return RGSS_KEY_F5;
  if(key == SDLK_F6) return RGSS_KEY_F6;
  if(key == SDLK_F7) return RGSS_KEY_F7;
  if(key == SDLK_F8) return RGSS_KEY_F8;
  if(key == SDLK_F9) return RGSS_KEY_F9;
  if(key == SDLK_F9) return RGSS_KEY_F9;
  // TODO: make keys configurable (via F1)
  if(key == SDLK_SPACE) return RGSS_KEY_C;
  if(key == SDLK_RETURN || key == SDLK_RETURN2) return RGSS_KEY_C;
  if(key == SDLK_ESCAPE) return RGSS_KEY_B;
  if(key == SDLK_KP_0) return RGSS_KEY_B;
  if(key == SDLK_LSHIFT || key == SDLK_RSHIFT) return RGSS_KEY_A;
#if RGSS >= 2
  if(key == SDLK_z) return RGSS_KEY_C;
  if(key == SDLK_x) return RGSS_KEY_B;
  if(key == SDLK_c) return -1;
#else
  if(key == SDLK_z) return RGSS_KEY_A;
  if(key == SDLK_x) return RGSS_KEY_B;
  if(key == SDLK_c) return RGSS_KEY_C;
#endif
  if(key == SDLK_v) return -1;
  if(key == SDLK_b) return -1;
  if(key == SDLK_a) return RGSS_KEY_X;
  if(key == SDLK_s) return RGSS_KEY_Y;
  if(key == SDLK_d) return RGSS_KEY_Z;
  if(key == SDLK_q) return RGSS_KEY_L;
  if(key == SDLK_w) return RGSS_KEY_R;
  return -1;
}

void keyPressed(SDL_Keycode key) {
  int rkey = convertSDLKey(key);
  if(rkey >= 0) {
    keycount2[rkey] = 0;
  }
}

void keyReleased(SDL_Keycode key) {
  int rkey = convertSDLKey(key);
  if(rkey >= 0) {
    keycount2[rkey] = -1;
  }
}
