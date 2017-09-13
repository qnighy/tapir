#include "RGSSError.h"

VALUE rb_eRGSSError;

/*
 * Raised from some RGSS methods.
 */
void Init_RGSSError(void) {
  rb_eRGSSError = rb_define_class("RGSSError", rb_eStandardError);
}
