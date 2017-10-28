// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

// Note: archive.c is intentionally left unimplemented.

#include "archive.h"
#include <stdlib.h>
#include <stdint.h>

#if RGSS == 3
#define RGSS_ARCHIVE_NAME "Game.rgss3a"
#elif RGSS == 2
#define RGSS_ARCHIVE_NAME "Game.rgss2a"
#else
#define RGSS_ARCHIVE_NAME "Game.rgssad"
#endif

static SDL_RWops *archive;

void initArchive(void) {
  archive = SDL_RWFromFile(RGSS_ARCHIVE_NAME, "rb");
  if(!archive) return;

  fprintf(stderr, "Tapir error: archive module not found\n");
  exit(1);
}

void deinitArchive(void) {
  if(archive) {
    SDL_RWclose(archive);
  }
}

bool archiveExists(void) {
  return archive != NULL;
}

SDL_RWops *openFromArchive(const char *path) {
  (void) path;
  return NULL;
}
