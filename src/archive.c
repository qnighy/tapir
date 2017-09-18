// Note: archive.c is intentionally left unimplemented.

#include <stdlib.h>
#include <stdint.h>
#include "archive.h"

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
