#ifndef SDL_MISC_H
#define SDL_MISC_H

#include <SDL.h>

struct Renderable {
  int flag;
};

extern int window_width;
extern int window_height;
extern SDL_Window *window;
extern SDL_Renderer *renderer;

void initSDL(void);
void cleanupSDL(void);
void renderSDL(void);

void registerRenderable(struct Renderable *renderable);
void unregisterRenderable(struct Renderable *renderable);

#endif /* SDL_MISC_H */
