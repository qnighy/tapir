#ifndef OPENRES_H
#define OPENRES_H

#include <stdbool.h>
#include <SDL.h>
#include <ruby.h>

// TODO: Make RTP base path configurable
// TODO: Make RTP name configurable (Game.ini)
// TODO: Support multiple RTPs (Game.ini)
#if RGSS == 3
#define RTP_PATH "/usr/local/share/Enterbrain/RGSS3/RPGVXAce"
#elif RGSS == 2
#define RTP_PATH "/usr/local/share/Enterbrain/RGSS2/RPGVX"
#else
#define RTP_PATH "/usr/local/share/Enterbrain/RGSS/Standard"
#endif

SDL_RWops *openres(VALUE path, bool use_archive);
VALUE rb_load_data(VALUE self, VALUE path);

#endif /* OPENRES_H */
