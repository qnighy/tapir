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
