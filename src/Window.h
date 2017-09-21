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
#if RGSS >= 2
  int openness;
#endif
};

bool rb_window_data_p(VALUE obj);
struct Window *rb_window_data(VALUE obj);
void rb_window_modify(VALUE obj);

void initWindowSDL(void);
void deinitWindowSDL(void);

#endif /* WINDOW_H */
