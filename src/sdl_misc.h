#ifndef SDL_MISC_H
#define SDL_MISC_H

#include <ruby.h>
#include <SDL.h>

struct Renderable {
  void (*render)(struct Renderable *renderable);
  int z;
  VALUE viewport;
};

extern int window_width;
extern int window_height;
extern int window_brightness;
extern SDL_Window *window;
extern SDL_Renderer *renderer;
extern SDL_GLContext glcontext;

void initSDL(void);
void cleanupSDL(void);
void event_loop(void);
void renderSDL(void);

void registerRenderable(struct Renderable *renderable);
void unregisterRenderable(struct Renderable *renderable);

#endif /* SDL_MISC_H */
