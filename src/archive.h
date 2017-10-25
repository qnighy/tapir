// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef ARCHIVE_H
#define ARCHIVE_H

#include <stdbool.h>
#include <SDL.h>

void initArchive(void);
void deinitArchive(void);
bool archiveExists(void);
SDL_RWops *openFromArchive(const char *path);

#endif /* ARCHIVE_H */
