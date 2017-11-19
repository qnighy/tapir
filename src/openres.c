// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "openres.h"
#include <sys/types.h>
#include <dirent.h>
#include "archive.h"
#include "misc.h"
#include "RGSSError.h"

static SDL_RWops *caseless_open(char *path, const char *mode);
static void modify_case(char *path);

SDL_RWops *openres(VALUE path, bool use_archive) {
  SDL_RWops *file;
  if(use_archive) {
    file = openFromArchive(StringValueCStr(path));
    if(file) return file;
  }
  for(ssize_t i = 0; i < RSTRING_LEN(path); ++i) {
    if(RSTRING_PTR(path)[i] == '\\') {
      RSTRING_PTR(path)[i] = '/';
    }
  }
  // TODO: support case-insensitive paths
  file = caseless_open(StringValueCStr(path), "rb");
  if(file) return file;
  VALUE path2 = rb_str_new2(RTP_PATH);
  rb_str_cat2(path2, "/");
  rb_str_concat(path2, path);
  rb_str_update(path, 0, RSTRING_LEN(path), path2);
  return caseless_open(StringValueCStr(path), "rb");
}

SDL_RWops *openres_ext(VALUE path, bool use_archive,
    const char * const exts[]) {
  for(; *exts; ++exts) {
    VALUE path2 = rb_str_new(RSTRING_PTR(path), RSTRING_LEN(path));
    rb_str_cat2(path2, *exts);
    SDL_RWops *file = openres(path2, use_archive);
    if(file) {
      rb_str_update(path, 0, RSTRING_LEN(path), path2);
      return file;
    }
  }
  return NULL;
}

VALUE rb_load_data(VALUE self, VALUE path) {
  (void) self;

  SDL_RWops *file = NULL;
  if(archiveExists()) {
    file = openFromArchive(StringValueCStr(path));
  } else {
    file = caseless_open(StringValueCStr(path), "rb");
  }
  if(!file) {
    rb_raise(rb_eRGSSError, "Couldn't open %s", StringValueCStr(path));
  }
  VALUE str = rb_str_new(0, 0);
  while(true) {
    char buf[1024];
    size_t numread = SDL_RWread(file, buf, 1, sizeof(buf));
    if(numread == 0) break;
    rb_str_cat(str, buf, numread);
  }
  SDL_RWclose(file);

  VALUE rb_mMarshal = rb_const_get_at(rb_cObject, rb_intern("Marshal"));
  return rb_funcall(rb_mMarshal, rb_intern("load"), 1, str);
}

static SDL_RWops *caseless_open(char *path, const char *mode) {
  SDL_RWops *file = SDL_RWFromFile(path, mode);
  if(file) return file;
  VALUE path2 = rb_str_new2(path);
  modify_case(RSTRING_PTR(path2));
  return SDL_RWFromFile(RSTRING_PTR(path2), mode);
}

static void modify_case(char *path) {
  // TODO: This routine only considers [a-zA-Z].
  // Actual Windows implementation compares case according to
  // lowercase/uppercase mapping from UnicodeData.txt.
  // TODO: path is assumed to be UTF-8 encoded, but opendir doesn't necessarily
  // use UTF-8.
  char *slash = strrchr(path, '/');
  char *basename;
  DIR *dir = NULL;
  if(slash == NULL) {
    basename = path;
    dir = opendir(".");
  } else if(slash == path) {
    basename = slash + 1;
    dir = opendir("/");
  } else {
    basename = slash + 1;
    *slash = '\0';
    dir = opendir(path);
    if(dir == NULL) {
      modify_case(path);
      dir = opendir(path);
    }
  }
  if(!dir) {
    if(slash) *slash = '/';
    return;
  }
  struct dirent *ent;
  while((ent = readdir(dir)) != NULL) {
    bool equal = true;
    for(int i = 0;; ++i) {
      char c1 = basename[i], c2 = ent->d_name[i];
      if('A' <= c1 && c1 <= 'Z') c1 |= 0x20;
      if('A' <= c2 && c2 <= 'Z') c2 |= 0x20;
      if(c1 != c2) {
        equal = false;
        break;
      }
      if(basename[i] == '\0') break;
    }
    if(equal) {
      strcpy(basename, ent->d_name);
      break;
    }
  }
  if(slash) *slash = '/';
  closedir(dir);
}
