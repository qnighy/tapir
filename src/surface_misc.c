// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "surface_misc.h"

#if SDL_BYTEORDER == SDL_BIG_ENDIAN
#define RMASK 0xff000000
#define GMASK 0x00ff0000
#define BMASK 0x0000ff00
#define AMASK 0x000000ff
#define PIXELFORMAT_RGBA32 SDL_PIXELFORMAT_RGBA8888
#else
#define RMASK 0x000000ff
#define GMASK 0x0000ff00
#define BMASK 0x00ff0000
#define AMASK 0xff000000
#define PIXELFORMAT_RGBA32 SDL_PIXELFORMAT_ABGR8888
#endif

SDL_Surface *create_rgba_surface(int width, int height) {
  return SDL_CreateRGBSurface(
      0, width, height, 32,
      RMASK, GMASK, BMASK, AMASK);
}

SDL_Surface *create_rgba_surface_from(SDL_Surface *orig) {
  SDL_Surface *ret =
    SDL_ConvertSurfaceFormat(orig, PIXELFORMAT_RGBA32, 0);
  SDL_FreeSurface(orig);
  return ret;
}
