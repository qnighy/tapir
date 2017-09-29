#include <stdio.h>
#include <stdlib.h>
#include "Audio.h"
#include "misc.h"
#include "sdl_misc.h"

VALUE rb_mAudio;

#if RGSS == 3
static VALUE rb_audio_s_setup_midi(VALUE klass);
#endif
static VALUE rb_audio_s_bgm_play(int argc, VALUE *argv, VALUE klass);
static VALUE rb_audio_s_bgm_stop(VALUE klass);
static VALUE rb_audio_s_bgm_fade(VALUE klass, VALUE time);
#if RGSS == 3
static VALUE rb_audio_s_bgm_pos(VALUE klass);
#endif
static VALUE rb_audio_s_bgs_play(int argc, VALUE *argv, VALUE klass);
static VALUE rb_audio_s_bgs_stop(VALUE klass);
static VALUE rb_audio_s_bgs_fade(VALUE klass, VALUE time);
#if RGSS == 3
static VALUE rb_audio_s_bgs_pos(VALUE klass);
#endif
static VALUE rb_audio_s_me_play(int argc, VALUE *argv, VALUE klass);
static VALUE rb_audio_s_me_stop(VALUE klass);
static VALUE rb_audio_s_me_fade(VALUE klass, VALUE time);
static VALUE rb_audio_s_se_play(int argc, VALUE *argv, VALUE klass);
static VALUE rb_audio_s_se_stop(VALUE klass);

void Init_Audio() {
  rb_mAudio = rb_define_module("Audio");
#if RGSS == 3
  rb_define_singleton_method(rb_mAudio, "setup_midi",
      rb_audio_s_setup_midi, 0);
#endif
  rb_define_singleton_method(rb_mAudio, "bgm_play", rb_audio_s_bgm_play, -1);
  rb_define_singleton_method(rb_mAudio, "bgm_stop", rb_audio_s_bgm_stop, 0);
  rb_define_singleton_method(rb_mAudio, "bgm_fade", rb_audio_s_bgm_fade, 1);
#if RGSS == 3
  rb_define_singleton_method(rb_mAudio, "bgm_pos", rb_audio_s_bgm_pos, 0);
#endif
  rb_define_singleton_method(rb_mAudio, "bgs_play", rb_audio_s_bgs_play, -1);
  rb_define_singleton_method(rb_mAudio, "bgs_stop", rb_audio_s_bgs_stop, 0);
  rb_define_singleton_method(rb_mAudio, "bgs_fade", rb_audio_s_bgs_fade, 1);
#if RGSS == 3
  rb_define_singleton_method(rb_mAudio, "bgs_pos", rb_audio_s_bgs_pos, 0);
#endif
  rb_define_singleton_method(rb_mAudio, "me_play", rb_audio_s_me_play, -1);
  rb_define_singleton_method(rb_mAudio, "me_stop", rb_audio_s_me_stop, 0);
  rb_define_singleton_method(rb_mAudio, "me_fade", rb_audio_s_me_fade, 1);
  rb_define_singleton_method(rb_mAudio, "se_play", rb_audio_s_se_play, -1);
  rb_define_singleton_method(rb_mAudio, "se_stop", rb_audio_s_se_stop, 0);
}

#if RGSS == 3
static VALUE rb_audio_s_setup_midi(VALUE klass) {
  (void) klass;
  WARN_UNIMPLEMENTED("Audio.setup_midi");
  return Qnil;
}
#endif

static VALUE rb_audio_s_bgm_play(int argc, VALUE *argv, VALUE klass) {
  (void) klass;
#if RGSS == 3
  if(argc <= 0 || argc > 4) {
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 1..4)", argc);
  }
#else
  if(argc <= 0 || argc > 3) {
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 1..3)", argc);
  }
#endif
  (void) argv;
  WARN_UNIMPLEMENTED("Audio.bgm_play");
  return Qnil;
}

static VALUE rb_audio_s_bgm_stop(VALUE klass) {
  (void) klass;
  WARN_UNIMPLEMENTED("Audio.bgm_stop");
  return Qnil;
}

static VALUE rb_audio_s_bgm_fade(VALUE klass, VALUE time) {
  (void) klass;
  (void) time;
  WARN_UNIMPLEMENTED("Audio.bgm_fade");
  return Qnil;
}

#if RGSS == 3
static VALUE rb_audio_s_bgm_pos(VALUE klass) {
  (void) klass;
  WARN_UNIMPLEMENTED("Audio.bgm_pos");
  return INT2NUM(0);
}
#endif

static VALUE rb_audio_s_bgs_play(int argc, VALUE *argv, VALUE klass) {
  (void) klass;
#if RGSS == 3
  if(argc <= 0 || argc > 4) {
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 1..4)", argc);
  }
#else
  if(argc <= 0 || argc > 3) {
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 1..3)", argc);
  }
#endif
  (void) argv;
  WARN_UNIMPLEMENTED("Audio.bgs_play");
  return Qnil;
}

static VALUE rb_audio_s_bgs_stop(VALUE klass) {
  (void) klass;
  WARN_UNIMPLEMENTED("Audio.bgs_stop");
  return Qnil;
}

static VALUE rb_audio_s_bgs_fade(VALUE klass, VALUE time) {
  (void) klass;
  (void) time;
  WARN_UNIMPLEMENTED("Audio.bgs_fade");
  return Qnil;
}

#if RGSS == 3
static VALUE rb_audio_s_bgs_pos(VALUE klass) {
  (void) klass;
  WARN_UNIMPLEMENTED("Audio.bgs_pos");
  return INT2NUM(0);
}
#endif

static VALUE rb_audio_s_me_play(int argc, VALUE *argv, VALUE klass) {
  (void) klass;
  if(argc <= 0 || argc > 3) {
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 1..3)", argc);
  }
  (void) argv;
  WARN_UNIMPLEMENTED("Audio.me_play");
  return Qnil;
}

static VALUE rb_audio_s_me_stop(VALUE klass) {
  (void) klass;
  WARN_UNIMPLEMENTED("Audio.me_stop");
  return Qnil;
}

static VALUE rb_audio_s_me_fade(VALUE klass, VALUE time) {
  (void) klass;
  (void) time;
  WARN_UNIMPLEMENTED("Audio.me_fade");
  return Qnil;
}

static VALUE rb_audio_s_se_play(int argc, VALUE *argv, VALUE klass) {
  (void) klass;
  if(argc <= 0 || argc > 3) {
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 1..3)", argc);
  }
  (void) argv;
  WARN_UNIMPLEMENTED("Audio.se_play");
  return Qnil;
}

static VALUE rb_audio_s_se_stop(VALUE klass) {
  (void) klass;
  WARN_UNIMPLEMENTED("Audio.se_stop");
  return Qnil;
}
