// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef BITMAP_ARRAY_H
#define BITMAP_ARRAY_H

#include <stdbool.h>
#include <ruby.h>

#include "sdl_misc.h"

#if RGSS >= 2
#define BITMAP_ARRAY_LENGTH 9
#define BITMAP_ARRAY_CLASS "Tilemap::BitmapArray"
#else
#define BITMAP_ARRAY_LENGTH 7
#define BITMAP_ARRAY_CLASS "TilemapAutotiles"
#endif

extern VALUE rb_cBitmapArray;
void Init_BitmapArray(void);

struct BitmapArray {
  VALUE data[BITMAP_ARRAY_LENGTH];
};

bool rb_bitmaparray_data_p(VALUE obj);
const struct BitmapArray *rb_bitmaparray_data(VALUE obj);
struct BitmapArray *rb_bitmaparray_data_mut(VALUE obj);

VALUE rb_bitmaparray_new(void);
void rb_bitmaparray_set2(VALUE self, VALUE other);

#endif /* BITMAP_ARRAY_H */
