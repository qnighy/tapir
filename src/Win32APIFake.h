// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef WIN32APIFAKE_H
#define WIN32APIFAKE_H

#include <ruby.h>

extern VALUE rb_cWin32APIFake;
void Init_Win32APIFake(void);

#endif /* WIN32APIFAKE_H */
