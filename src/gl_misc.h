// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#ifndef GL_MISC_H
#define GL_MISC_H

#define GL_GLEXT_PROTOTYPES
#include <SDL.h>
#include <SDL_opengl.h>
#include <SDL_opengl_glext.h>

GLuint compileShaders(const char *vsh_source, const char *fsh_source);
void gl_draw_rect(
    double x0, double y0, double x1, double y1,
    double tx0, double ty0, double tx1, double ty1);

#endif /* GL_MISC_H */
