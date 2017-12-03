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
#include <sys/stat.h>
#include <dirent.h>
#include <unistd.h>
#include <errno.h>
#include "archive.h"
#include "misc.h"
#include "tapir_config.h"
#include "RGSSError.h"

#if RGSS == 3
#define RTP_BASE_DETECTOR "/RGSS3/RPGVXAce/Graphics/Titles1/Castle.png"
#define RTP_RGSS_VERSION "RGSS3"
#elif RGSS == 2
#define RTP_BASE_DETECTOR "/RGSS2/RPGVX/Graphics/System/Title.png"
#define RTP_RGSS_VERSION "RGSS2"
#else
#define RTP_BASE_DETECTOR "/RGSS/Standard/Graphics/Titles/001-Title01.jpg"
#define RTP_RGSS_VERSION "RGSS"
#endif

static char *rtp_paths[NUM_RTP_SLOTS];

const char *get_rtp_path(int rtp_slot) {
  return rtp_paths[rtp_slot];
}

void configure_rtp_path(struct ini_section *game_section) {
  const char *rtp_base_path = get_rtp_base_config();
  if(!rtp_base_path) {
    static const char *rtp_base_candidates[] = {
      // "/opt/Enterbrain",
      "/usr/local/share/Enterbrain",
      "/usr/share/Enterbrain",
      NULL
    };
    for(int i = 0; rtp_base_candidates[i]; ++i) {
      const char *rtp_base_candidate = rtp_base_candidates[i];
      char *detect_path = malloc(
          strlen(rtp_base_candidate) +
          strlen(RTP_BASE_DETECTOR) + 1);
      strcpy(detect_path, rtp_base_candidate);
      strcat(detect_path, RTP_BASE_DETECTOR);
      struct stat buf;
      int result = stat(detect_path, &buf);
      free(detect_path);
      if(result == 0) {
        rtp_base_path = rtp_base_candidate;
        break;
      }
    }
  }

#if RGSS >= 2
  const char *rtp_names[NUM_RTP_SLOTS] = {NULL};
#else
  const char *rtp_names[NUM_RTP_SLOTS] = {NULL, NULL, NULL};
#endif
  if(game_section) {
#if RGSS >= 2
    rtp_names[0] = find_ini_entry(game_section, "RTP");
#else
    rtp_names[0] = find_ini_entry(game_section, "RTP1");
    rtp_names[1] = find_ini_entry(game_section, "RTP2");
    rtp_names[2] = find_ini_entry(game_section, "RTP3");
#endif
  }
  for(int i = 0; i < NUM_RTP_SLOTS; ++i) {
    rtp_paths[i] = NULL;

    if(!rtp_names[i]) {
      rtp_names[i] = "";
    }
    if(!strcmp(rtp_names[i], "")) continue;
    const char *rtp_path_from_config = get_rtp_config(rtp_names[i]);
    if(rtp_path_from_config) {
      rtp_paths[i] = strdup(rtp_path_from_config);
      continue;
    }

    // RTP default fallback
    if(!rtp_base_path) {
      fprintf(stderr, "warning: could not find RTP %s\n", rtp_names[i]);
      continue;
    }

    size_t rtp_path_len =
        strlen(rtp_base_path) +
        1 + strlen(RTP_RGSS_VERSION) +
        1 + strlen(rtp_names[i]);
    rtp_paths[i] = malloc(rtp_path_len + 1);
    snprintf(rtp_paths[i], rtp_path_len + 1, "%s/%s/%s",
        rtp_base_path, RTP_RGSS_VERSION, rtp_names[i]);
  }
}

void deconfigure_rtp_path() {
  for(int i = 0; i < NUM_RTP_SLOTS; ++i) {
    if(rtp_paths[i]) {
      free(rtp_paths[i]);
      rtp_paths[i] = NULL;
    }
  }
}

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
  for(int rtp_slot = 0; rtp_slot < NUM_RTP_SLOTS; ++rtp_slot) {
    const char *rtp_path = get_rtp_path(rtp_slot);
    if(!rtp_path) continue;
    VALUE path2 = rb_str_new2(rtp_path);
    rb_str_cat2(path2, "/");
    rb_str_concat(path2, path);
    rb_str_update(path, 0, RSTRING_LEN(path), path2);
    file = caseless_open(StringValueCStr(path), "rb");
    if(file) return file;
  }
  return NULL;
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

static bool script_loading_flag = false;

void flag_script_loading(void) {
  script_loading_flag = true;
}

VALUE rb_load_data(VALUE self, VALUE path) {
  (void) self;

  bool script_loading = script_loading_flag;
  script_loading_flag = false;

  SDL_RWops *file = NULL;
  if(archiveExists()) {
    file = openFromArchive(StringValueCStr(path));
  }
  if(!file && (!archiveExists() || !script_loading)) {
    file = caseless_open(StringValueCStr(path), "rb");
  }
  if(!file) {
    errno = ENOENT;
    rb_sys_fail(StringValueCStr(path));
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
