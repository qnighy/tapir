#ifndef SDL_MISC_H
#define SDL_MISC_H

#include <stdbool.h>
#include <ruby.h>
#include <SDL.h>

struct RenderJob;

struct Renderable {
  void (*prepare)(struct Renderable *renderable, int t);
  void (*render)(struct Renderable *renderable, const struct RenderJob *job);
  bool disposed;
};

struct RenderJob {
  struct Renderable *renderable;
  int z, y, t, aux[3];
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
void capturedRenderSDL(SDL_Surface *surface);

void registerRenderable(struct Renderable *renderable);
void disposeRenderable(struct Renderable *renderable);
void disposeAll(void);

void queueRenderJob(struct RenderJob job);

#endif /* SDL_MISC_H */
