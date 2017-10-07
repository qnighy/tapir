#ifndef VIEWPORT_H
#define VIEWPORT_H

#include <stdbool.h>
#include <ruby.h>
#include "sdl_misc.h"

extern VALUE rb_cViewport;
void Init_Viewport(void);

struct Viewport {
  struct Renderable renderable;
  struct RenderQueue viewport_queue;
  VALUE rect, color, tone;
  bool visible;
  int ox, oy, z;
};

bool rb_viewport_data_p(VALUE obj);
const struct Viewport *rb_viewport_data(VALUE obj);
struct Viewport *rb_viewport_data_mut(VALUE obj);

#endif /* VIEWPORT_H */
