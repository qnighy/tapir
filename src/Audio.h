// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef AUDIO_H
#define AUDIO_H

#include <ruby.h>
#include <SDL.h>

extern VALUE rb_mAudio;
void Init_Audio(void);

void initAudioSDL(void);
void deinitAudioSDL(void);

#endif /* AUDIO_H */
