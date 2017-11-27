// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "tapir_config.h"
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

config_t tapir_config;

#if RGSS == 3
static const char * const version_name = "rgss3";
#elif RGSS == 2
static const char * const version_name = "rgss2";
#else
static const char * const version_name = "rgss1";
#endif

#if RGSS >= 2
int key_config[KEYCONFIG_LEN] = {
  0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x00, 0x00,
  0x0d, 0x0d, 0x0c, 0x0c, 0x0b,
  0x0d, 0x0c, 0x00, 0x00, 0x00, 0x0e, 0x0f, 0x10, 0x11, 0x12
};
#else
int key_config[KEYCONFIG_LEN] = {
  0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x00, 0x00,
  0x0d, 0x0d, 0x0c, 0x0c, 0x0b,
  0x0b, 0x0c, 0x0d, 0x00, 0x00, 0x0e, 0x0f, 0x10, 0x11, 0x12
};
#endif

static const char * const button_names[KEYCONFIG_LEN] = {
  "button1",
  "button2",
  "button3",
  "button4",
  "button5",
  "button6",
  "button7",
  "button8",
  "button9",
  "button10",
  "space",
  "enter",
  "esc",
  "num0",
  "shift",
  "key_z",
  "key_x",
  "key_c",
  "key_v",
  "key_b",
  "key_a",
  "key_s",
  "key_d",
  "key_q",
  "key_w"
};

static int convert_keyname(const char *key);
static void process_setting(config_setting_t *setting);

void init_tapir_config(void) {
  config_init(&tapir_config);
  struct stat dummy_buf;

  if(stat("/etc/tapir.cfg", &dummy_buf) == 0 &&
      !config_read_file(&tapir_config, "/etc/tapir.cfg")) {
    fprintf(stderr, "Error reading %s: %s:%d: %s\n",
        "/etc/tapir.cfg",
        config_error_file(&tapir_config),
        config_error_line(&tapir_config),
        config_error_text(&tapir_config));
  }

  const char *homedir = getenv("HOME");
  if(homedir) {
    size_t tapircfg_len = strlen(homedir) + strlen("/.tapir.cfg");
    char *tapircfg = malloc(tapircfg_len + 1);
    snprintf(tapircfg, tapircfg_len + 1, "%s%s", homedir, "/.tapir.cfg");

    if(stat(tapircfg, &dummy_buf) == 0 &&
        !config_read_file(&tapir_config, tapircfg)) {
      fprintf(stderr, "Error reading %s: %s:%d: %s\n",
          tapircfg,
          config_error_file(&tapir_config),
          config_error_line(&tapir_config),
          config_error_text(&tapir_config));
    }
  }

  config_setting_t *setting = config_lookup(&tapir_config, "rgss");
  if(setting) {
    process_setting(setting);
  }

  config_setting_t *vsetting = config_lookup(&tapir_config, version_name);
  if(vsetting) {
    process_setting(vsetting);
  }
}

void deinit_tapir_config(void) {
  config_destroy(&tapir_config);
}

static void process_setting(config_setting_t *setting) {
  for(int i = 0; i < KEYCONFIG_LEN; ++i) {
    const char *value;
    if(config_setting_lookup_string(setting, button_names[i], &value)) {
      key_config[i] = convert_keyname(value);
    }
  }
}

static int convert_keyname(const char *key) {
  if(!strcmp(key, "")) {
    return 0;
  } if(!strcmp(key, "A")) {
    return 0x0b;
  } else if(!strcmp(key, "B")) {
    return 0x0c;
  } else if(!strcmp(key, "C")) {
    return 0x0d;
  } else if(!strcmp(key, "X")) {
    return 0x0e;
  } else if(!strcmp(key, "Y")) {
    return 0x0f;
  } else if(!strcmp(key, "Z")) {
    return 0x10;
  } else if(!strcmp(key, "L")) {
    return 0x11;
  } else if(!strcmp(key, "R")) {
    return 0x12;
  } else {
    fprintf(stderr, "Invalid key name: %s (expected one of A, B, C, X, Y, Z, L, R)\n", key);
    return 0;
  }
}

const char *get_rtp_config(const char *rtp_name) {
  config_setting_t *vsetting = config_lookup(&tapir_config, version_name);
  if(!vsetting) return NULL;

  config_setting_t *rsetting = config_setting_lookup(vsetting, "rtp");
  if(!rsetting) return NULL;

  const char *value;
  if(config_setting_lookup_string(rsetting, rtp_name, &value)) {
    return value;
  } else {
    return NULL;
  }
}

const char *get_rtp_base_config() {
  config_setting_t *setting = config_lookup(&tapir_config, "rgss");
  if(!setting) return NULL;

  const char *value;
  if(config_setting_lookup_string(setting, "rtp_base_path", &value)) {
    return value;
  } else {
    return NULL;
  }
}
