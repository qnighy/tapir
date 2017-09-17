#include <stdio.h>
#include <stdlib.h>
#include <SDL_opengl.h>
#include "sdl_misc.h"

#if RGSS >= 2
int window_width = 544;
int window_height = 416;
#else
int window_width = 640;
int window_height = 480;
#endif
SDL_Window *window = NULL;
SDL_GLContext glcontext = NULL;
static size_t registry_size, registry_capacity;
static struct Renderable **registry;

void initSDL() {
  registry_capacity = 100;
  registry = malloc(sizeof(*registry) * registry_capacity);

  if(SDL_Init(SDL_INIT_VIDEO)) {
    fprintf(stderr, "SDL_Init Error: %s\n", SDL_GetError());
    exit(1);
  }

  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);

  /* TODO: fetch window title from Game.ini */
  window = SDL_CreateWindow("tapir",
      SDL_WINDOWPOS_CENTERED,
      SDL_WINDOWPOS_CENTERED,
      window_width, window_height,
      SDL_WINDOW_OPENGL);
  if(!window) {
    fprintf(stderr, "SDL_CreateWindow Error: %s\n", SDL_GetError());
    SDL_Quit();
    exit(1);
  }

  // int major, minor;
  // SDL_GL_GetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, &major);
  // SDL_GL_GetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, &minor);
  // fprintf(stderr, "GL version: %d.%d\n", major, minor);

  glcontext = SDL_GL_CreateContext(window);
  if(!glcontext) {
    fprintf(stderr, "SDL_GL_CreateContext error: %s\n", SDL_GetError());
    SDL_DestroyWindow(window);
    SDL_Quit();
    exit(1);
  }
}

void cleanupSDL() {
  SDL_GL_DeleteContext(glcontext);
  SDL_DestroyWindow(window);
  SDL_Quit();
  free(registry);
}

void renderSDL() {
  // TODO: implement rendering
  SDL_GL_MakeCurrent(window, glcontext);
  glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  for(size_t i = 0; i < registry_size; ++i) {
    registry[i]->render(registry[i]);
  }
  SDL_GL_SwapWindow(window);
}

void registerRenderable(struct Renderable *renderable) {
  if(registry_size >= registry_capacity) {
    registry_capacity = registry_capacity + registry_capacity / 2;
    registry = realloc(registry, sizeof(*registry) * registry_capacity);
  }
  registry[registry_size++] = renderable;
}

void unregisterRenderable(struct Renderable *renderable) {
  size_t i;
  for(i = 0; i < registry_size; ++i) {
    if(registry[i] == renderable) break;
  }
  if(i == registry_size) return;
  registry[i] = registry[registry_size - 1];
  --registry_size;
}
