#ifndef COLOR_H
#define COLOR_H

#include <stdbool.h>
#include <ruby.h>

extern VALUE rb_cColor;
extern void Init_Color(void);

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
