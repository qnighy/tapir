// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

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

void initSDL(const char *window_title);
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

void freeze_screen(void);
void defreeze_screen(void);
void load_transition_image(const char *filename, int vagueness);

SDL_Surface *create_rgba_surface(int width, int height);
SDL_Surface *create_rgba_surface_from(SDL_Surface *orig);

#endif /* SDL_MISC_H */
