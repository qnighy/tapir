#ifndef SDL_MISC_H
#define SDL_MISC_H

#include <stdbool.h>
#include <ruby.h>
#include <SDL.h>

struct RenderViewport {
  int width, height;
  int ox, oy;
};

struct RenderJob;

struct Renderable {
  void (*clear)(struct Renderable *renderable);
  void (*prepare)(struct Renderable *renderable, int t);
  void (*render)(struct Renderable *renderable, const struct RenderJob *job,
      const struct RenderViewport *viewport);
  bool disposed;
};

struct RenderJob {
  struct Renderable *renderable;
  int z, y, t, aux[3];
};

struct RenderQueue {
  size_t size, capacity;
  struct RenderJob *queue;
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

void initRenderQueue(struct RenderQueue *queue);
void clearRenderQueue(struct RenderQueue *queue);
void renderQueue(struct RenderQueue *queue,
    const struct RenderViewport *viewport);
void queueRenderJob(VALUE viewport, struct RenderJob job);
void deinitRenderQueue(struct RenderQueue *queue);

#endif /* SDL_MISC_H */
