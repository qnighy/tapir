// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef MISC_H
#define MISC_H

#include <stdint.h>
#include <ruby.h>

#ifndef RSTRING_PTR
#define RSTRING_PTR(s) (RSTRING(s)->ptr)
#endif
#ifndef RSTRING_LEN
#define RSTRING_LEN(s) (RSTRING(s)->len)
#endif
#ifndef DBL2NUM
#define DBL2NUM(dbl) rb_float_new(dbl)
#endif

int32_t saturateInt32(int32_t val, int32_t minval, int32_t maxval);
double saturateDouble(double val, double minval, double maxval);

double readDouble(const char *ptr);
void writeDouble(char *ptr, double val);
int32_t readInt32(const char *ptr);
void writeInt32(char *ptr, int32_t val);
int16_t readInt16(const char *ptr);
void writeInt16(char *ptr, int16_t val);

void tryChdir(const char *path);

#define WARN_UNIMPLEMENTED(name) do { \
    static int warned = 0; \
    if(!warned) { \
      warned = 1; \
      fprintf(stderr, "unimplemented: %s\n", name); \
    } \
  } while(0)

#endif /* MISC_H */
