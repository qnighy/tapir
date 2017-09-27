#include "RGSSReset.h"

VALUE rb_eRGSSReset;

/*
 * Raised when reset key is pressed.
 */
void Init_RGSSReset(void) {
#if RGSS == 3
  rb_eRGSSReset = rb_define_class("RGSSReset", rb_eException);
#else
  rb_eRGSSReset = rb_define_class_id(rb_intern("Reset"), rb_eException);
#endif
}
