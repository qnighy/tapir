#include <stdio.h>
#include <stdlib.h>
#include <SDL.h>
#include "sdl_misc.h"

static int window_width = 640;
static int window_height = 480;
static SDL_Window *window = NULL;
static SDL_Renderer *renderer = NULL;

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

  renderer = SDL_CreateRenderer(
      window, -1,
      SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
  if(!renderer) {
    fprintf(stderr, "SDL_CreateRenderer Error: %s\n", SDL_GetError());
    SDL_DestroyWindow(window);
    SDL_Quit();
    exit(1);
  }
}

void loopSDL() {
  SDL_Event e;
  int quit = 0;
  while(!quit) {
    while(SDL_PollEvent(&e)) {
      switch(e.type) {
        case SDL_QUIT:
          quit = 1;
          break;
      }
    }
    SDL_RenderClear(renderer);
    SDL_RenderPresent(renderer);
    SDL_Delay(1000 / 60);
  }
}

void cleanupSDL() {
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit();
}
