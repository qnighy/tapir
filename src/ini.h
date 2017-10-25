// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef INI_H
#define INI_H

#include <stdlib.h>

extern int ansi_code_page;

struct ini_entry {
  char *key, *value;
};

struct ini_section {
  char *name;
  size_t capacity, size;
  struct ini_entry *entries;
};

struct ini {
  size_t capacity, size;
  struct ini_section **sections;
};

struct ini *load_ini(const char *filename, int codepage);
struct ini_section *new_ini_section(const char *name);
void free_ini_section(struct ini_section *section);
void add_ini_entry(
    struct ini_section *section, const char *key, const char *value);
const char *find_ini_entry(struct ini_section *section, const char *key);
struct ini *new_ini(void);
void free_ini(struct ini *data);
void add_ini_section(struct ini *data, struct ini_section *section);
struct ini_section *find_ini_section(struct ini *data, const char *name);

#endif /* INI_H */
