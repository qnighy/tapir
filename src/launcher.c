// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "ini.h"
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <errno.h>
#include <libgen.h>

static void tryChdir(const char *path);

int main(int argc, char **argv) {
  char *exec_base = NULL;
  if(strchr(argv[0], '/')) {
    char *exec_file = strdup(argv[0]);
    exec_base = realpath(dirname(exec_file), NULL);
    free(exec_file);
  }


  bool is_test_mode = false;
  bool is_btest_mode = false;
  bool is_console_mode = false;
  bool help = false;
  int rgss = -1;

  int argpos = 1;
  while(argpos < argc) {
    if(!strcmp(argv[argpos], "btest")) {
      is_test_mode = is_btest_mode = true;
    } else if(!strcmp(argv[argpos], "test") ||
        !strcmp(argv[argpos], "debug")) {
      is_test_mode = true;
    } else if(!strcmp(argv[argpos], "console")) {
      is_console_mode = true;
    } else if(!strcmp(argv[argpos], "-d") && argpos+1 < argc) {
      ++argpos;
      tryChdir(argv[argpos]);
    } else if(!strcmp(argv[argpos], "-1")) {
      rgss = 1;
    } else if(!strcmp(argv[argpos], "-2")) {
      rgss = 2;
    } else if(!strcmp(argv[argpos], "-3")) {
      rgss = 3;
    } else if(!strcmp(argv[argpos], "-h") || !strcmp(argv[argpos], "--help")) {
      help = true;
    } else {
      fprintf(stderr, "warning: unrecognized argument: %s\n", argv[argpos]);
    }
    ++argpos;
  }

  if(help) {
    fprintf(stderr,
        "Tapir: RGSS (RPG Maker XP, VX and VX Ace) compatible game engine\n"
        "\n"
        "Usage: ./tapir [-h] [-d DIR] [-1] [-2] [-3] [test] [btest] [console]\n"
        "    -h      show this help\n"
        "    -d DIR  move to DIR before running the game\n"
        "    -1      force RGSS version 1 (RPG Maker XP)\n"
        "    -2      force RGSS version 2 (RPG Maker VX)\n"
        "    -3      force RGSS version 3 (RPG Maker VX Ace)\n"
        "    test    enable test mode\n"
        "    btest   enable battle test mode\n"
        "    console show console (not yet implemented)\n"
      );
    return 0;
  }

  if(rgss == -1) {
    struct ini *ini_data = load_ini("Game.ini", 0);
    struct ini_section *game_section =
      ini_data ? find_ini_section(ini_data, "Game") : NULL;
    const char *game_library =
      game_section ? find_ini_entry(game_section, "Library") : NULL;
    if(game_library) {
      if(strstr(game_library, "RGSS1")) {
        rgss = 1;
      } else if(strstr(game_library, "RGSS2")) {
        rgss = 2;
      } else if(strstr(game_library, "RGSS3")) {
        rgss = 3;
      }
    }
    if(ini_data) free_ini(ini_data);
  }

  if(rgss == -1) {
    fprintf(stderr, "Error: could not determine RGSS version\n");
    return 1;
  }

  // Make e.g. "./tapir-x" from "./tapir"
  char *exec;
  if(exec_base) {
    // argv[0] is an absolute/relative path.
    size_t exec_len = strlen(exec_base) + strlen("/tapir-0");
    exec = malloc(exec_len + 1);
    snprintf(exec, exec_len + 1, "%s/tapir-%c", exec_base, "0xva"[rgss]);
  } else {
    // argv[0] refers to $PATH exec.
    size_t exec_len = strlen("tapir-0");
    exec = malloc(exec_len + 1);
    snprintf(exec, exec_len + 1, "tapir-%c", "0xva"[rgss]);
  }

  int exec_argc = 0;
  char *exec_argv[6];
  exec_argv[exec_argc++] = exec;
  if(is_btest_mode) exec_argv[exec_argc++] = "btest";
  else if(is_test_mode && rgss >= 2) exec_argv[exec_argc++] = "test";
  else if(is_test_mode) exec_argv[exec_argc++] = "debug";
  if(is_console_mode) exec_argv[exec_argc++] = "console";
  exec_argv[exec_argc] = NULL;

  execvp(exec, exec_argv);

  fprintf(stderr, "Error: failed to execute %s: %s\n", exec, strerror(errno));

  return 0;
}

static void tryChdir(const char *path) {
  if(chdir(path)) {
    fprintf(stderr, "cannot chdir: %s\n", strerror(errno));
  }
}
