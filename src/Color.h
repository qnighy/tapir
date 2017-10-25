// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef COLOR_H
#define COLOR_H

#include <stdbool.h>
#include <ruby.h>

extern VALUE rb_cColor;
void Init_Color(void);

struct Color {
  double red, green, blue, alpha;
};

bool rb_color_data_p(VALUE obj);
const struct Color *rb_color_data(VALUE obj);
struct Color *rb_color_data_mut(VALUE obj);

VALUE rb_color_new(double red, double green, double blue, double alpha);
VALUE rb_color_new2(void);
bool rb_color_equal(VALUE self, VALUE other);
void rb_color_set(
    VALUE self, double newred, double newgreen, double newblue,
    double newalpha);
void rb_color_set2(VALUE self, VALUE other);
double rb_color_red(VALUE self);
void rb_color_set_red(VALUE self, double newval);
double rb_color_green(VALUE self);
void rb_color_set_green(VALUE self, double newval);
double rb_color_blue(VALUE self);
void rb_color_set_blue(VALUE self, double newval);
double rb_color_alpha(VALUE self);
void rb_color_set_alpha(VALUE self, double newval);

#endif /* COLOR_H */
