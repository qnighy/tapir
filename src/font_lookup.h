#ifndef FONT_LOOKUP_H
#define FONT_LOOKUP_H

#include <stdbool.h>
#include <SDL.h>
#include <SDL_ttf.h>

void initFontLookup(void);
void uninitFontLookup(void);

bool fontExistence(const char *name);
TTF_Font *loadFont(const char *name, int size, bool bold, bool italic);

#endif /* FONT_LOOKUP_H */
