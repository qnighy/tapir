#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <SDL_image.h>
#include <SDL_mixer.h>
#include <SDL_ttf.h>
#include "gl_misc.h"
#include "sdl_misc.h"
#include "Sprite.h"
#include "Plane.h"
#include "Window.h"
#include "Input.h"
#include "Audio.h"
#include "RGSSReset.h"
#include "Tilemap.h"

#if SDL_BYTEORDER == SDL_BIG_ENDIAN
#define RMASK 0xff000000
#define GMASK 0x00ff0000
#define BMASK 0x0000ff00
#define AMASK 0x000000ff
#define PIXELFORMAT_RGBA32 SDL_PIXELFORMAT_RGBA8888
#else
#define RMASK 0x000000ff
#define GMASK 0x0000ff00
#define BMASK 0x00ff0000
#define AMASK 0xff000000
#define PIXELFORMAT_RGBA32 SDL_PIXELFORMAT_ABGR8888
#endif

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

static size_t jobqueue_size, jobqueue_capacity;
static struct RenderJob *jobqueue;

static GLuint transition_shader;

static void initTransition(void);
static void deinitTransition(void);

void initSDL() {
  registry_capacity = 100;
  registry = malloc(sizeof(*registry) * registry_capacity);

  jobqueue_capacity = 100;
  jobqueue = malloc(sizeof(*jobqueue) * jobqueue_capacity);

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

  if(Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024) < 0) {
    printf("Mix_OpenAudio Error: %s\n", Mix_GetError());
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
  if(jobqueue) free(jobqueue);
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
  jobqueue_size = 0;
  for(size_t t = 0; t < registry_size; ++t) {
    registry[t]->prepare(registry[t], t);
  }
  qsort(jobqueue, jobqueue_size, sizeof(*jobqueue), compare_jobs);
  for(size_t i = 0; i < jobqueue_size; ++i) {
    jobqueue[i].renderable->render(jobqueue[i].renderable, &jobqueue[i]);
  }
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
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glUseProgram(transition_shader);
    glUniform1f(glGetUniformLocation(transition_shader, "brightness"),
        window_brightness / 255.0);

    gl_draw_rect(-1.0, -1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0);

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

void queueRenderJob(struct RenderJob job) {
  if(jobqueue_size >= jobqueue_capacity) {
    jobqueue_capacity = jobqueue_capacity + jobqueue_capacity / 2;
    jobqueue = realloc(jobqueue, sizeof(*jobqueue) * jobqueue_capacity);
  }
  jobqueue[jobqueue_size++] = job;
}

static void initTransition(void) {
  static const char *vsh_source =
    "#version 120\n"
    "\n"
    "void main(void) {\n"
    "    gl_Position = gl_Vertex;\n"
    "}\n";

  static const char *fsh_source =
    "#version 120\n"
    "#if __VERSION__ >= 130\n"
    "#define texture2D texture\n"
    "#define texture2DProj textureProj\n"
    "#endif\n"
    "\n"
    "uniform float brightness;\n"
    "\n"
    "void main(void) {\n"
    "    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0 - brightness);\n"
    "}\n";

  transition_shader = compileShaders(vsh_source, fsh_source);
}
static void deinitTransition(void) {
  if(transition_shader) glDeleteProgram(transition_shader);
}
