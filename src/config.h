// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef CONFIG_H
#define CONFIG_H

#include <libconfig.h>

#define KEYCONFIG_LEN 25

extern config_t tapir_config;
extern int key_config[KEYCONFIG_LEN];

void init_tapir_config(void);
void deinit_tapir_config(void);

int get_key_config(int button);

#endif /* CONFIG_H */
