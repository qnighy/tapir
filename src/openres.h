// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef OPENRES_H
#define OPENRES_H

#include <stdbool.h>
#include <SDL.h>
#include <ruby.h>

// TODO: Make RTP base path configurable
// TODO: Make RTP name configurable (Game.ini)
// TODO: Support multiple RTPs (Game.ini)
#if RGSS == 3
#define RTP_PATH DATA_DIR "/Enterbrain/RGSS3/RPGVXAce"
#elif RGSS == 2
#define RTP_PATH DATA_DIR "/Enterbrain/RGSS2/RPGVX"
#else
#define RTP_PATH DATA_DIR "/Enterbrain/RGSS/Standard"
#endif

SDL_RWops *openres(VALUE path, bool use_archive);
SDL_RWops *openres_ext(VALUE path, bool use_archive,
    const char * const exts[]);
VALUE rb_load_data(VALUE self, VALUE path);

#endif /* OPENRES_H */
