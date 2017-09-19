#ifndef FONT_H
#define FONT_H

#include <stdbool.h>
#include <ruby.h>

extern VALUE rb_cFont;
extern void Init_Font(void);

struct Font {
  VALUE name;
  int size;
  bool bold, italic;
#if RGSS == 3
  bool outline;
#endif
#if RGSS >= 2
  bool shadow;
#endif
  VALUE color;
#if RGSS == 3
  VALUE out_color;
#endif
};

bool isFont(VALUE obj);
struct Font *convertFont(VALUE obj);
void rb_font_modify(VALUE obj);

#endif /* FONT_H */
