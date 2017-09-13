#include <stdio.h>
#include <stdlib.h>
#include "sdl_misc.h"

int window_width = 640;
int window_height = 480;
SDL_Window *window = NULL;
SDL_Renderer *renderer = NULL;

void initSDL() {
  if(SDL_Init(SDL_INIT_VIDEO)) {
    fprintf(stderr, "SDL_Init Error: %s\n", SDL_GetError());
    exit(1);
  }

  /* TODO: fetch window title from Game.ini */
  window = SDL_CreateWindow("tapir",
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

void cleanupSDL() {
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit();
}
