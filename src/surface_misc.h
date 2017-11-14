// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef SURFACE_MISC_H
#define SURFACE_MISC_H

#include <SDL.h>

SDL_Surface *create_rgba_surface(int width, int height);
SDL_Surface *create_rgba_surface_from(SDL_Surface *orig);

#endif /* SURFACE_MISC_H */
