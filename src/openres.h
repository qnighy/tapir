#ifndef OPENRES_H
#define OPENRES_H

#include <SDL.h>

SDL_RWops *openres(const char *path);
VALUE rb_load_data(VALUE self, VALUE path);

#endif /* OPENRES_H */
