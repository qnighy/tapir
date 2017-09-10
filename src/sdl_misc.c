#include <stdio.h>
#include <stdlib.h>
#include <SDL.h>
#include "sdl_misc.h"

static int window_width = 640;
static int window_height = 480;
static SDL_Window *window = NULL;

void initSDL() {
  if(SDL_Init(SDL_INIT_VIDEO)) {
    fprintf(stderr, "SDL_Init Error: %s\n", SDL_GetError());
    exit(1);
  }

  window = SDL_CreateWindow("hoge",
      SDL_WINDOWPOS_CENTERED,
      SDL_WINDOWPOS_CENTERED,
      window_width, window_height, SDL_WINDOW_SHOWN);
  if(!window) {
    fprintf(stderr, "SDL_CreateWindow Error: %s\n", SDL_GetError());
    SDL_Quit();
    exit(1);
  }
}

void cleanupSDL() {
  SDL_DestroyWindow(window);
  SDL_Quit();
}
