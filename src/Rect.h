#ifndef RECT_H
#define RECT_H

#include <stdbool.h>
#include <stdint.h>
#include <ruby.h>

extern VALUE rb_cRect;
extern void Init_Rect(void);

struct Rect {
  int32_t x, y, width, height;
};

bool isRect(VALUE obj);
struct Rect *convertRect(VALUE obj);
void rb_rect_modify(VALUE obj);

VALUE rb_rect_new(int32_t x, int32_t y, int32_t width, int32_t height);
VALUE rb_rect_new2(void);
bool rb_rect_equal(VALUE self, VALUE other);
void rb_rect_set(
    VALUE self, int32_t newx, int32_t newy,
    int32_t newwidth, int32_t newheight);
void rb_rect_set2(VALUE self, VALUE other);
int32_t rb_rect_x(VALUE self);
void rb_rect_set_x(VALUE self, int32_t newx);
int32_t rb_rect_y(VALUE self);
void rb_rect_set_y(VALUE self, int32_t newy);
int32_t rb_rect_width(VALUE self);
void rb_rect_set_width(VALUE self, int32_t newwidth);
int32_t rb_rect_height(VALUE self);
void rb_rect_set_height(VALUE self, int32_t newheight);

#endif /* RECT_H */
