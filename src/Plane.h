// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef PLANE_H
#define PLANE_H

#include <stdbool.h>
#include <ruby.h>

#include "sdl_misc.h"

extern VALUE rb_cPlane;
void Init_Plane(void);

struct Plane {
  struct Renderable renderable;
  VALUE viewport, bitmap, color, tone;
  bool visible;
  int z, ox, oy, opacity, blend_type;
  double zoom_x, zoom_y;
};

bool rb_plane_data_p(VALUE obj);
const struct Plane *rb_plane_data(VALUE obj);
struct Plane *rb_plane_data_mut(VALUE obj);

void initPlaneSDL(void);
void deinitPlaneSDL(void);

#endif /* PLANE_H */
