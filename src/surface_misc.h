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

#if SDL_BYTEORDER == SDL_BIG_ENDIAN
#define RGBA32_R(rgba) (((rgba) >> 24) & 0xff)
#define RGBA32_G(rgba) (((rgba) >> 16) & 0xff)
#define RGBA32_B(rgba) (((rgba) >> 8) & 0xff)
#define RGBA32_A(rgba) ((rgba) & 0xff)
#define RGBA32(r, g, b, a) (((r) << 24) | ((g) << 16) | ((b) << 8) | (a))
#else
#define RGBA32_R(rgba) ((rgba) & 0xff)
#define RGBA32_G(rgba) (((rgba) >> 8) & 0xff)
#define RGBA32_B(rgba) (((rgba) >> 16) & 0xff)
#define RGBA32_A(rgba) (((rgba) >> 24) & 0xff)
#define RGBA32(r, g, b, a) ((r) | ((g) << 8) | ((b) << 16) | ((a) << 24))
#endif

SDL_Surface *create_rgba_surface(int width, int height);
SDL_Surface *create_rgba_surface_from(SDL_Surface *orig);

#endif /* SURFACE_MISC_H */
