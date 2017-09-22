#ifndef WINDOW_H
#define WINDOW_H

#include <stdbool.h>
#include <ruby.h>

#include "sdl_misc.h"

extern VALUE rb_cWindow;
void Init_Window(void);

struct Window {
  struct Renderable renderable;
  VALUE windowskin, contents;
  bool disposed, visible;
  int x, y, width, height;
  int ox, oy;
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
