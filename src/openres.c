#include "openres.h"
#include "misc.h"

// TODO: Make RTP base path configurable
// TODO: Make RTP name configurable (Game.ini)
// TODO: Support multiple RTPs (Game.ini)
#if RGSS == 3
#define RTP_PATH "/usr/local/share/Enterbrain/RGSS3/RPGVXAce"
#elif RGSS == 2
#define RTP_PATH "/usr/local/share/Enterbrain/RGSS2/RPGVX"
#else
#define RTP_PATH "/usr/local/share/Enterbrain/RGSS/Standard"
#endif

SDL_RWops *openres(const char *path) {
  // TODO: support case-insensitive paths
  // TODO: support '\\' delimiter
  SDL_RWops *file = SDL_RWFromFile(path, "rb");
  if(file) return file;
  VALUE path2 = rb_str_new2(RTP_PATH);
  rb_str_cat2(path2, "/");
  rb_str_cat2(path2, path);
  return SDL_RWFromFile(RSTRING_PTR(path2), "rb");
}
