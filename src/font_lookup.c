// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "font_lookup.h"
#include <stdio.h>
#include <stdlib.h>
#include <fontconfig/fontconfig.h>
#include "openres.h"

static FcConfig *config = NULL;

void initFontLookup(void) {
  if(!FcInit()) {
    fprintf(stderr, "FcInit failed\n");
    exit(1);
  }
  config = FcInitLoadConfigAndFonts();
  // TODO case-insensitive paths
  FcConfigAppFontAddDir(config, (const FcChar8 *)"Fonts");
  FcConfigAppFontAddDir(config, (const FcChar8 *)(RTP_PATH "/Fonts"));
}

void uninitFontLookup(void) {
  if(config) {
    FcConfigDestroy(config);
    config = NULL;
  }
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

TTF_Font *loadFont(const char *name, int size, bool bold, bool italic) {
  // TODO: cache font here to avoid multiple loading

  // fprintf(stderr, "loadFont(%s, %d, %d, %d)\n", name, size, bold, italic);

  FcPattern* pat = FcPatternCreate();
  FcPatternAddString(pat, FC_FAMILY, (const FcChar8 *)name);
  FcPatternAddInteger(pat, FC_SIZE, size);
  FcPatternAddInteger(pat, FC_WEIGHT,
      bold ? FC_WEIGHT_BOLD : FC_WEIGHT_MEDIUM);
  FcPatternAddInteger(pat, FC_SLANT,
      italic ? FC_SLANT_ITALIC : FC_SLANT_ROMAN);

  FcConfigSubstitute(config, pat, FcMatchPattern);
  FcDefaultSubstitute(pat);

  FcResult result;
  FcPattern* font = FcFontMatch(config, pat, &result);
  if(!font) {
    fprintf(stderr, "No font found!\n");
    exit(1);
  }

  const char *path;
  if(FcPatternGetString(font, FC_FILE, 0, (FcChar8 **)&path) != FcResultMatch) {
    fprintf(stderr, "Fontconfig failed!\n");
    exit(1);
  }

  int index;
  if(FcPatternGetInteger(font, FC_INDEX, 0, &index) != FcResultMatch) {
    fprintf(stderr, "Fontconfig failed!\n");
    exit(1);
  }

  // fprintf(stderr, "font = %s, index = %d\n", path, index);

  TTF_Font *sdl_font = TTF_OpenFontIndex(path, size, index);

  TTF_SetFontStyle(sdl_font,
      (bold ? TTF_STYLE_BOLD : 0) | (italic ? TTF_STYLE_ITALIC : 0));

  FcPatternDestroy(font);
  FcPatternDestroy(pat);

  return sdl_font;
}
