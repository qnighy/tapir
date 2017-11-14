// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "sdl_misc.h"
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <SDL_image.h>
#include <SDL_mixer.h>
#include <SDL_ttf.h>
#include "misc.h"
#include "gl_misc.h"
#include "surface_misc.h"
#include "openres.h"
#include "Sprite.h"
#include "Plane.h"
#include "Window.h"
#include "Input.h"
#include "Audio.h"
#include "RGSSError.h"
#include "RGSSReset.h"
#include "Tilemap.h"
#include "Viewport.h"

#if RGSS >= 2
int window_width = 544;
int window_height = 416;
#else
int window_width = 640;
int window_height = 480;
#endif
int window_brightness = 255;
SDL_Window *window = NULL;
SDL_GLContext glcontext = NULL;

static size_t registry_size, registry_capacity;
static struct Renderable **registry;

static struct RenderQueue main_queue;

static GLuint transition_shader;
static GLuint transition_texture;
static GLuint transition_texture2;
static int transition_vagueness = 255;

static void initTransition(void);
static void deinitTransition(void);

void initSDL(const char *window_title) {
  registry_capacity = 100;
  registry = malloc(sizeof(*registry) * registry_capacity);

  initRenderQueue(&main_queue);

  if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)) {
    fprintf(stderr, "SDL_Init Error: %s\n", SDL_GetError());
    exit(1);
  }

  int img_flags = IMG_INIT_JPG|IMG_INIT_PNG|IMG_INIT_TIF;
  if(IMG_Init(img_flags) != img_flags) {
    fprintf(stderr, "IMG_Init Error: %s\n", IMG_GetError());
    exit(1);
  }

  if(TTF_Init()) {
    fprintf(stderr, "TTF_Init Error: %s\n", TTF_GetError());
    exit(1);
  }

  int mix_init_flags = Mix_Init(MIX_INIT_MP3|MIX_INIT_OGG);
  if((mix_init_flags & MIX_INIT_MP3) == 0) {
    fprintf(stderr, "Mix_Init warning: could not init MP3\n");
  }
  if((mix_init_flags & MIX_INIT_OGG) == 0) {
    fprintf(stderr, "Mix_Init warning: could not init OGG\n");
  }

  // TODO: in some environment, SDL_mixer produces unignorable latency...
  if(Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024) < 0) {
    printf("Mix_OpenAudio Error: %s\n", Mix_GetError());
    exit(1);
  }

  Mix_AllocateChannels(16);

  // int mix_frequency, mix_channels;
  // Uint16 mix_format;
  // Mix_QuerySpec(&mix_frequency, &mix_format, &mix_channels);
  // fprintf(stderr, "frequency = %d, format = %d, channels = %d\n",
  //     mix_frequency, (int)mix_format, mix_channels);

  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);

  window = SDL_CreateWindow(window_title,
      SDL_WINDOWPOS_CENTERED,
      SDL_WINDOWPOS_CENTERED,
      window_width, window_height,
      SDL_WINDOW_OPENGL);
  if(!window) {
    fprintf(stderr, "SDL_CreateWindow Error: %s\n", SDL_GetError());
    exit(1);
  }

  // int major, minor;
  // SDL_GL_GetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, &major);
  // SDL_GL_GetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, &minor);
  // fprintf(stderr, "GL version: %d.%d\n", major, minor);

  glcontext = SDL_GL_CreateContext(window);
  if(!glcontext) {
    fprintf(stderr, "SDL_GL_CreateContext error: %s\n", SDL_GetError());
    exit(1);
  }

  initTransition();
  initSpriteSDL();
  initWindowSDL();
  initTilemapSDL();
  initPlaneSDL();
  initAudioSDL();
}

void cleanupSDL() {
  deinitAudioSDL();
  deinitPlaneSDL();
  deinitTilemapSDL();
  deinitWindowSDL();
  deinitSpriteSDL();
  deinitTransition();
  if(glcontext) SDL_GL_DeleteContext(glcontext);
  if(window) SDL_DestroyWindow(window);
  Mix_CloseAudio();
  Mix_Quit();
  TTF_Quit();
  IMG_Quit();
  SDL_Quit();
  deinitRenderQueue(&main_queue);
  if(registry) free(registry);
}

static int compare_jobs(const void *o1, const void *o2) {
  const struct RenderJob *j1 = (const struct RenderJob *)o1;
  const struct RenderJob *j2 = (const struct RenderJob *)o2;

  if(j1->z < j2->z) return -1;
  else if(j1->z > j2->z) return 1;

  if(j1->y < j2->y) return -1;
  else if(j1->y > j2->y) return 1;

  if(j1->t < j2->t) return -1;
  else if(j1->t > j2->t) return 1;

  return 0;
}

void event_loop() {
  SDL_Event e;
  int quit = 0;

  while(SDL_PollEvent(&e)) {
    switch(e.type) {
      case SDL_KEYDOWN:
        if(e.key.keysym.sym == SDLK_F12) {
          rb_raise(rb_eRGSSReset, "RGSS Reset");
        }
        if(!e.key.repeat) {
          keyPressed(e.key.keysym.sym);
        }
        break;
      case SDL_KEYUP:
        keyReleased(e.key.keysym.sym);
        break;
      case SDL_QUIT:
        quit = 1;
        break;
    }
  }

  if(quit) {
    exit(0);
  }
}

static void renderScreen() {
  clearRenderQueue(&main_queue);
  for(size_t t = 0; t < registry_size; ++t) {
    if(registry[t]->clear) registry[t]->clear(registry[t]);
  }
  for(size_t t = 0; t < registry_size; ++t) {
    registry[t]->prepare(registry[t], t);
  }
  struct RenderViewport viewport;
  viewport.width = window_width;
  viewport.height = window_height;
  viewport.ox = 0;
  viewport.oy = 0;
  renderQueue(&main_queue, &viewport);
}

void renderSDL() {
  SDL_GL_MakeCurrent(window, glcontext);
  glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  glScissor(0, 0, window_width, window_height);
  glViewport(0, 0, window_width, window_height);
  renderScreen();

  if(window_brightness != 255) {
    // transition

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glBlendEquation(GL_FUNC_ADD);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, transition_texture2);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, transition_texture);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glUseProgram(transition_shader);
    glUniform1i(glGetUniformLocation(transition_shader, "tex"), 0);
    glUniform1i(glGetUniformLocation(transition_shader, "tex2"), 1);
    glUniform2f(glGetUniformLocation(transition_shader, "resolution"),
        window_width, window_height);
    glUniform1f(glGetUniformLocation(transition_shader, "brightness"),
        window_brightness / 255.0);
    glUniform1f(glGetUniformLocation(transition_shader, "vagueness"),
        transition_vagueness / 255.0);

    gl_draw_rect(
        0, 0, window_width, window_height, 0.0, 0.0, 1.0, 1.0);

    glUseProgram(0);
  }

  SDL_GL_SwapWindow(window);
}

void capturedRenderSDL(SDL_Surface *surface) {
  SDL_GL_MakeCurrent(window, glcontext);
  glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  glScissor(0, 0, window_width, window_height);
  glViewport(0, 0, window_width, window_height);
  renderScreen();

  glReadPixels(0, 0, window_width, window_height,
      GL_RGBA, GL_UNSIGNED_BYTE, surface->pixels);

  // Swap y
  //
  Uint32 *pixels = (Uint32 *)surface->pixels;
  size_t h = surface->h;
  size_t w = surface->w;
  size_t pitch = surface->pitch / 4;

  for(size_t y0 = 0; y0 * 2 + 1 < h; ++y0) {
    size_t y1 = h - 1 - y0;
    for(size_t x = 0; x < w; ++x) {
      Uint32 c0 = pixels[y0 * pitch + x];
      pixels[y0 * pitch + x] = pixels[y1 * pitch + x];
      pixels[y1 * pitch + x] = c0;
    }
  }
}

void registerRenderable(struct Renderable *renderable) {
  if(registry_size >= registry_capacity) {
    registry_capacity = registry_capacity + registry_capacity / 2;
    registry = realloc(registry, sizeof(*registry) * registry_capacity);
  }
  registry[registry_size++] = renderable;
}

void disposeRenderable(struct Renderable *renderable) {
  if(renderable->disposed) return;
  renderable->disposed = true;

  size_t i;
  for(i = 0; i < registry_size; ++i) {
    if(registry[i] == renderable) break;
  }
  if(i == registry_size) return;
  for(; i + 1 < registry_size; ++i) {
    registry[i] = registry[i + 1];
  }
  --registry_size;
}

void disposeAll(void) {
  // TODO: dispose all Bitmaps too
  for(size_t i = 0; i < registry_size; ++i) {
    registry[i]->disposed = true;
  }
  registry_size = 0;
}

void initRenderQueue(struct RenderQueue *queue) {
  queue->capacity = 100;
  queue->queue = malloc(sizeof(*queue->queue) * queue->capacity);
}

void clearRenderQueue(struct RenderQueue *queue) {
  queue->size = 0;
}

void renderQueue(struct RenderQueue *queue,
    const struct RenderViewport *viewport) {
  qsort(queue->queue, queue->size, sizeof(*queue->queue), compare_jobs);
  for(size_t i = 0; i < queue->size; ++i) {
    struct RenderJob *job = &queue->queue[i];
    job->renderable->render(job->renderable, job, viewport);
  }
}

void deinitRenderQueue(struct RenderQueue *queue) {
  if(queue->queue) free(queue->queue);
}

void queueRenderJob(VALUE viewport, struct RenderJob job) {
  struct RenderQueue *queue = &main_queue;
  if(viewport != Qnil) {
    queue = &((struct Viewport *)rb_viewport_data(viewport))->viewport_queue;
  }
  if(queue->size >= queue->capacity) {
    queue->capacity = queue->capacity + queue->capacity / 2;
    queue->queue = realloc(
        queue->queue, sizeof(*queue->queue) * queue->capacity);
  }
  queue->queue[queue->size++] = job;
}

void freeze_screen(void) {
  SDL_Surface *frozen = create_rgba_surface(window_width, window_height);
  capturedRenderSDL(frozen);
  glBindTexture(GL_TEXTURE_2D, transition_texture);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frozen->w, frozen->h,
      0, GL_RGBA, GL_UNSIGNED_BYTE, frozen->pixels);
  SDL_FreeSurface(frozen);
}

void defreeze_screen(void) {
  SDL_Surface *frozen = create_rgba_surface(window_width, window_height);
  SDL_FillRect(frozen, NULL, SDL_MapRGBA(frozen->format, 0, 0, 0, 255));
  glBindTexture(GL_TEXTURE_2D, transition_texture);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frozen->w, frozen->h,
      0, GL_RGBA, GL_UNSIGNED_BYTE, frozen->pixels);
  SDL_FreeSurface(frozen);
}

void load_transition_image(const char *filename, int vagueness) {
  if(!filename || !strcmp(filename, "")) {
    SDL_Surface *img = create_rgba_surface(window_width, window_height);
    SDL_FillRect(img, NULL, SDL_MapRGBA(img->format, 255, 255, 255, 255));
    glBindTexture(GL_TEXTURE_2D, transition_texture2);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, img->w, img->h,
        0, GL_RGBA, GL_UNSIGNED_BYTE, img->pixels);
    SDL_FreeSurface(img);

    transition_vagueness = 255;
    return;
  }

  SDL_Surface *transition_image = NULL;

  {
    const char * const extensions[] = {"", ".png", NULL};
    VALUE filename2 = rb_str_new2(filename);
    SDL_RWops *file = openres_ext(filename2, true, extensions);
    if(!file) {
      /* TODO: check error handling */
      rb_raise(rb_eRGSSError, "Error loading %s: %s",
          filename, SDL_GetError());
    }
    /* TODO: limit file type */
    SDL_Surface *img = IMG_Load_RW(file, true);
    if(!img) {
      /* TODO: check error handling */
      rb_raise(rb_eRGSSError, "Error loading %s: %s",
          filename, IMG_GetError());
    }
    transition_image = create_rgba_surface_from(img);
  }

  glBindTexture(GL_TEXTURE_2D, transition_texture2);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
      transition_image->w, transition_image->h,
      0, GL_RGBA, GL_UNSIGNED_BYTE, transition_image->pixels);
  SDL_FreeSurface(transition_image);

  transition_vagueness = vagueness;
}

static void initTransition(void) {
  static const char *vsh_source =
    "#version 120\n"
    "\n"
    "uniform vec2 resolution;\n"
    "\n"
    "void main(void) {\n"
    "    gl_TexCoord[0] = gl_MultiTexCoord0;\n"
    "    gl_Position.x = gl_Vertex.x / resolution.x * 2.0 - 1.0;\n"
    "    gl_Position.y = 1.0 - gl_Vertex.y / resolution.y * 2.0;\n"
    "    gl_Position.zw = vec2(0.0, 1.0);\n"
    "}\n";

  static const char *fsh_source =
    "#version 120\n"
    "#if __VERSION__ >= 130\n"
    "#define texture2D texture\n"
    "#define texture2DProj textureProj\n"
    "#endif\n"
    "\n"
    "uniform sampler2D tex;\n"
    "uniform sampler2D tex2;\n"
    "uniform float brightness;\n"
    "uniform float vagueness;\n"
    "\n"
    "void main(void) {\n"
    "    float tr = texture2D(tex2, gl_TexCoord[0].xy).r;\n"
    "    float br = \n"
    "      (brightness - (tr - vagueness)) / \n"
    "      (vagueness + 0.0000001);\n"
    "    br = max(min(br, 1.0), 0.0);\n"
    "    gl_FragColor = texture2D(tex, gl_TexCoord[0].xy);\n"
    "    gl_FragColor.a *= 1.0 - br;\n"
    "    /* premultiplication */\n"
    "    gl_FragColor.rgb *= gl_FragColor.a;\n"
    "}\n";

  transition_shader = compileShaders(vsh_source, fsh_source);

  glGenTextures(1, &transition_texture);
  glGenTextures(1, &transition_texture2);

  defreeze_screen();
  load_transition_image(NULL, 255);
}
static void deinitTransition(void) {
  if(transition_texture2) glDeleteTextures(1, &transition_texture2);
  if(transition_texture) glDeleteTextures(1, &transition_texture);
  if(transition_shader) glDeleteProgram(transition_shader);
}
