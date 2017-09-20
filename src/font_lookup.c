#include <stdio.h>
#include <stdlib.h>
#include <fontconfig/fontconfig.h>
#include "font_lookup.h"

static FcConfig *config;

void initFontLookup(void) {
  if(!FcInit()) {
    fprintf(stderr, "FcInit failed\n");
    exit(1);
  }
  config = FcInitLoadConfigAndFonts();
}

void uninitFontLookup(void) {
  FcConfigDestroy(config);
  config = NULL;
  FcFini();
}

bool fontExistence(const char *name) {
  // fprintf(stderr, "fontExistence(%s)\n", name);

  FcPattern* pat = FcNameParse((const FcChar8 *)name);
  FcConfigSubstitute(config, pat, FcMatchPattern);
  FcDefaultSubstitute(pat);

  FcResult result;
  FcPattern* font = FcFontMatch(config, pat, &result);
  bool exists = (font != NULL);
  FcPatternDestroy(font);
  FcPatternDestroy(pat);
  return exists;
}
