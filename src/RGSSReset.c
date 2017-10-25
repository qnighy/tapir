// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "RGSSReset.h"

VALUE rb_eRGSSReset;

/*
 * Raised when reset key is pressed.
 */
void Init_RGSSReset(void) {
#if RGSS == 3
  rb_eRGSSReset = rb_define_class("RGSSReset", rb_eException);
#else
  rb_eRGSSReset = rb_define_class("Reset", rb_eException);
  rb_mod_remove_const(rb_cObject, ID2SYM(rb_intern("Reset")));
#endif
}
