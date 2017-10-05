#ifndef WINDOW_H
#define WINDOW_H

#include <stdbool.h>
#include <ruby.h>

#include "sdl_misc.h"

extern VALUE rb_cWindow;
void Init_Window(void);

struct Window {
  struct Renderable renderable;
  VALUE viewport, windowskin, contents, cursor_rect;
#if RGSS == 3
  VALUE tone;
#endif
  bool disposed, visible, active, pause;
#if RGSS == 3
  bool arrows_visible;
#endif
#if RGSS == 1
  bool stretch;
#endif
  int x, y, z, width, height;
  int ox, oy;
  int opacity, back_opacity, contents_opacity;
#if RGSS == 3
  int padding, padding_bottom;
#endif
#if RGSS >= 2
  int openness;
#endif
};

bool rb_window_data_p(VALUE obj);
const struct Window *rb_window_data(VALUE obj);
struct Window *rb_window_data_mut(VALUE obj);

void initWindowSDL(void);
void deinitWindowSDL(void);

#endif /* WINDOW_H */
