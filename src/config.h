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
