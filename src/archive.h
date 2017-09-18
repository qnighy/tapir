#ifndef ARCHIVE_H
#define ARCHIVE_H

#include <stdbool.h>
#include <SDL.h>

void initArchive(void);
void deinitArchive(void);
bool archiveExists(void);
SDL_RWops *openFromArchive(const char *path);

#endif /* ARCHIVE_H */
