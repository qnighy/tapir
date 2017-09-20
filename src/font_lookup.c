#include <stdio.h>
#include <fontconfig/fontconfig.h>
#include "font_lookup.h"

static FcConfig *config;

void initFontLookup(void) {
  config = FcInitLoadConfigAndFonts();
}

void uninitFontLookup(void) {
}

bool fontExistence(const char *name) {
  // fprintf(stderr, "fontExistence(%s)\n", name);

  FcPattern* pat = FcNameParse((const FcChar8 *)name);
  FcConfigSubstitute(config, pat, FcMatchPattern);
  FcDefaultSubstitute(pat);

  FcResult result;
  FcPattern* font = FcFontMatch(config, pat, &result);
  bool exists = (font != NULL);
  FcPatternDestroy(pat);
  return exists;
}
