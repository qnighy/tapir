// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "Audio.h"
#include <stdio.h>
#include <stdlib.h>
#include <SDL.h>
#include <SDL_mixer.h>
#include "RGSSError.h"
#include "misc.h"
#include "sdl_misc.h"
#include "openres.h"

VALUE rb_mAudio;

struct chunk_cache_entry {
  char *name;
  Mix_Chunk *chunk;
};

// TODO: properly close these
static Mix_Music *bgm;

static size_t chunk_cache_size, chunk_cache_capacity;
static struct chunk_cache_entry *chunk_cache;

static Mix_Chunk *load_chunk_cached(VALUE filename);

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
  int volume = argc > 1 ? saturateInt32(NUM2INT(argv[1]), 0, 100) : 100;
  int pitch = argc > 2 ? saturateInt32(NUM2INT(argv[2]), 50, 150) : 100;
  int pos = argc > 3 ? NUM2INT(argv[3]) : 0;

  if(pitch != 100) {
    WARN_UNIMPLEMENTED("Audio.bgm_play with pitch");
  }

  if(pos != 0) {
    WARN_UNIMPLEMENTED("Audio.bgm_play with pos");
  }

  if(bgm) {
    Mix_HaltMusic();
    Mix_FreeMusic(bgm);
    bgm = NULL;
  }

  const char * const extensions[] = {
    "", ".ogg", ".wma", ".mp3", ".wav", ".mid", NULL};
  VALUE filename = rb_str_new(RSTRING_PTR(argv[0]), RSTRING_LEN(argv[0]));
  SDL_RWops *file = openres_ext(filename, false, extensions);
  if(!file) {
    /* TODO: check error handling */
    rb_raise(rb_eRGSSError, "Error loading %s: %s",
        StringValueCStr(argv[0]),
        SDL_GetError());
  }
  SDL_RWclose(file);
  bgm = Mix_LoadMUS(StringValueCStr(filename));
  if(!bgm) {
    /* TODO: check error handling */
    rb_raise(rb_eRGSSError, "Error loading %s: %s",
        StringValueCStr(argv[0]),
        Mix_GetError());
  }
  Mix_VolumeMusic(volume * MIX_MAX_VOLUME / 100);
  // TODO: LOOPSTART from ogg
  Mix_PlayMusic(bgm, -1);
  return Qnil;
}

static VALUE rb_audio_s_bgm_stop(VALUE klass) {
  (void) klass;
  if(bgm) {
    Mix_HaltMusic();
    Mix_FreeMusic(bgm);
    bgm = NULL;
  }
  return Qnil;
}

static VALUE rb_audio_s_bgm_fade(VALUE klass, VALUE time) {
  (void) klass;
  int time_i = NUM2INT(time);
  if(bgm) {
    Mix_FadeOutMusic(time_i);
    Mix_FreeMusic(bgm);
    bgm = NULL;
  }
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
  int volume = argc > 1 ? saturateInt32(NUM2INT(argv[1]), 0, 100) : 80;
  int pitch = argc > 2 ? saturateInt32(NUM2INT(argv[2]), 50, 150) : 100;

  if(pitch != 100) {
    WARN_UNIMPLEMENTED("Audio.se_play with pitch");
  }

  Mix_Chunk *chunk = load_chunk_cached(argv[0]);
  if(!chunk) return Qnil;

  fprintf(stderr, "Audio.se_play(\"%s\", %d, %d)\n",
      StringValueCStr(argv[0]), volume, pitch);

  Mix_VolumeChunk(chunk, volume * MIX_MAX_VOLUME / 100);
  Mix_PlayChannel(-1, chunk, 0);


  return Qnil;
}

static VALUE rb_audio_s_se_stop(VALUE klass) {
  (void) klass;
  WARN_UNIMPLEMENTED("Audio.se_stop");
  return Qnil;
}

static Mix_Chunk *load_chunk_cached(VALUE filename) {
  const char *filename_c = StringValueCStr(filename);
  for(size_t i = 0; i < chunk_cache_size; ++i) {
    if(!strcmp(chunk_cache[i].name, filename_c)) {
      return chunk_cache[i].chunk;
    }
  }

  const char * const extensions[] = {
    "", ".ogg", ".wma", ".mp3", ".wav", ".mid", NULL};
  filename = rb_str_new(RSTRING_PTR(filename), RSTRING_LEN(filename));
  SDL_RWops *file = openres_ext(filename, false, extensions);
  if(!file) {
    /* TODO: check error handling */
    rb_raise(rb_eRGSSError, "Error loading %s: %s",
        StringValueCStr(filename),
        SDL_GetError());
  }

  Mix_Chunk *chunk = Mix_LoadWAV_RW(file, 1);

  if(!chunk) return NULL;

  if(chunk_cache_size <= chunk_cache_capacity) {
    chunk_cache_capacity += chunk_cache_capacity / 2;
    chunk_cache = realloc(chunk_cache,
        sizeof(*chunk_cache) * chunk_cache_capacity);
  }

  chunk_cache[chunk_cache_size].chunk = chunk;
  chunk_cache[chunk_cache_size].name = strdup(filename_c);
  chunk_cache_size++;

  return chunk;
}

void initAudioSDL(void) {
  chunk_cache_size = 0;
  chunk_cache_capacity = 10;
  chunk_cache = malloc(sizeof(*chunk_cache) * chunk_cache_capacity);
}

void deinitAudioSDL(void) {
  if(bgm) Mix_FreeMusic(bgm);
  Mix_HaltChannel(-1);
  for(size_t i = 0; i < chunk_cache_size; ++i) {
    Mix_FreeChunk(chunk_cache[i].chunk);
    free(chunk_cache[i].name);
  }
  free(chunk_cache);
}
