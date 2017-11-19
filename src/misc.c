// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "misc.h"
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

int32_t saturateInt32(int32_t val, int32_t minval, int32_t maxval) {
  if(val <= minval) return minval;
  if(val >= maxval) return maxval;
  return val;
}

// Note: original RGSS seems to evaluate to_f twice or more.
double saturateDouble(double val, double minval, double maxval) {
  // Note: original RGSS doesn't check NaN.
  if(val <= minval) return minval;
  if(val >= maxval) return maxval;
  if(minval <= val && val <= maxval) return val;
  // rb_raise(rb_eRangeError, "cannot saturate NaN");
  return 0.0;
}

union u64d_converter {
  uint64_t u64;
  double d;
};

double readDouble(const char *ptr) {
  union u64d_converter num;
  num.u64 =
    ((uint64_t)(unsigned char)ptr[0])|
    ((uint64_t)(unsigned char)ptr[1]<<8)|
    ((uint64_t)(unsigned char)ptr[2]<<16)|
    ((uint64_t)(unsigned char)ptr[3]<<24)|
    ((uint64_t)(unsigned char)ptr[4]<<32)|
    ((uint64_t)(unsigned char)ptr[5]<<40)|
    ((uint64_t)(unsigned char)ptr[6]<<48)|
    ((uint64_t)(unsigned char)ptr[7]<<56);
  return num.d;
}

void writeDouble(char *ptr, double val) {
  union u64d_converter num;
  num.d = val;
  ptr[0] = num.u64;
  ptr[1] = num.u64>>8;
  ptr[2] = num.u64>>16;
  ptr[3] = num.u64>>24;
  ptr[4] = num.u64>>32;
  ptr[5] = num.u64>>40;
  ptr[6] = num.u64>>48;
  ptr[7] = num.u64>>56;
}

int32_t readInt32(const char *ptr) {
  return
    ((uint32_t)(unsigned char)ptr[0])|
    ((uint32_t)(unsigned char)ptr[1]<<8)|
    ((uint32_t)(unsigned char)ptr[2]<<16)|
    ((uint32_t)(unsigned char)ptr[3]<<24);
}

void writeInt32(char *ptr, int32_t val) {
  ptr[0] = ((uint32_t)val);
  ptr[1] = ((uint32_t)val)>>8;
  ptr[2] = ((uint32_t)val)>>16;
  ptr[3] = ((uint32_t)val)>>24;
}

int16_t readInt16(const char *ptr) {
  return
    ((uint16_t)(unsigned char)ptr[0])|
    ((uint16_t)(unsigned char)ptr[1]<<8);
}

void writeInt16(char *ptr, int16_t val) {
  ptr[0] = ((uint16_t)val);
  ptr[1] = ((uint16_t)val)>>8;
}


void tryChdir(const char *path) {
  if(chdir(path)) {
    fprintf(stderr, "cannot chdir: %s\n", strerror(errno));
  }
}
