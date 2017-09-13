#ifndef TONE_H
#define TONE_H

#include <stdbool.h>
#include <ruby.h>

extern VALUE rb_cTone;
extern void Init_Tone(void);

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
