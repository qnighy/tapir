#ifndef FONT_LOOKUP_H
#define FONT_LOOKUP_H

#include <stdbool.h>

void initFontLookup(void);
void uninitFlotLookup(void);

bool fontExistence(const char *name);

#endif /* FONT_LOOKUP_H */
