// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

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

bool rb_rect_data_p(VALUE obj);
const struct Rect *rb_rect_data(VALUE obj);
struct Rect *rb_rect_data_mut(VALUE obj);

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
