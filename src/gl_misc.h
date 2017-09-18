#ifndef GL_MISC_H
#define GL_MISC_H

#define GL_GLEXT_PROTOTYPES
#include <SDL.h>
#include <SDL_opengl.h>
#include <SDL_opengl_glext.h>

GLuint compileShaders(const char *vsh_source, const char *fsh_source);

#endif /* GL_MISC_H */
