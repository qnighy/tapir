#ifndef SDL_MISC_H
#define SDL_MISC_H

#include <SDL.h>

extern int window_width;
extern int window_height;
extern SDL_Window *window;
extern SDL_Renderer *renderer;

void initSDL(void);
void cleanupSDL(void);

#endif /* SDL_MISC_H */
