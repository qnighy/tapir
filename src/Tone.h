// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef TONE_H
#define TONE_H

#include <stdbool.h>
#include <ruby.h>

extern VALUE rb_cTone;
extern void Init_Tone(void);

struct Tone {
  double red, green, blue, gray;
};

bool rb_tone_data_p(VALUE obj);
const struct Tone *rb_tone_data(VALUE obj);
struct Tone *rb_tone_data_mut(VALUE obj);

VALUE rb_tone_new(double red, double green, double blue, double gray);
VALUE rb_tone_new2(void);
bool rb_tone_equal(VALUE self, VALUE other);
void rb_tone_set(
    VALUE self, double newred, double newgreen, double newblue,
    double newgray);
void rb_tone_set2(VALUE self, VALUE other);
double rb_tone_red(VALUE self);
void rb_tone_set_red(VALUE self, double newval);
double rb_tone_green(VALUE self);
void rb_tone_set_green(VALUE self, double newval);
double rb_tone_blue(VALUE self);
void rb_tone_set_blue(VALUE self, double newval);
double rb_tone_gray(VALUE self);
void rb_tone_set_gray(VALUE self, double newval);

#endif /* TONE_H */
