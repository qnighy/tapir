#ifndef OPENRES_H
#define OPENRES_H

#include <ruby.h>
#include <SDL.h>

SDL_RWops *openres(VALUE path);

#endif /* OPENRES_H */
