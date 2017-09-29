#ifndef OPENRES_H
#define OPENRES_H

#include <stdbool.h>
#include <SDL.h>

SDL_RWops *openres(VALUE path, bool use_archive);
VALUE rb_load_data(VALUE self, VALUE path);

#endif /* OPENRES_H */
