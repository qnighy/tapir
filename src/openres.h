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
#include "ini.h"

#if RGSS >= 2
#define NUM_RTP_SLOTS 1
#else
#define NUM_RTP_SLOTS 3
#endif

const char *get_rtp_path(int rtp_slot);
void configure_rtp_path(struct ini_section *game_section);
void deconfigure_rtp_path(void);

SDL_RWops *openres(VALUE path, bool use_archive);
SDL_RWops *openres_ext(VALUE path, bool use_archive,
    const char * const exts[]);
// TODO: this is a dirty hack -- only the first call of `rb_load_data`
//       after this function is considered "script loading", that means
//       it will only look into the archive provided it exists.
void flag_script_loading(void);
VALUE rb_load_data(VALUE self, VALUE path);

#endif /* OPENRES_H */
