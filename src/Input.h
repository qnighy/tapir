// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef INPUT_H
#define INPUT_H

#include <ruby.h>
#include <SDL.h>

extern VALUE rb_mInput;
void Init_Input(void);

void keyPressed(SDL_Keycode key);
void keyReleased(SDL_Keycode key);

#endif /* INPUT_H */
