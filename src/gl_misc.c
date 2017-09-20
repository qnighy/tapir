#include "gl_misc.h"

GLuint compileShaders(const char *vsh_source, const char *fsh_source) {
  GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vsh, 1, &vsh_source, NULL);
  glCompileShader(vsh);
  {
    int compilation_status;
    glGetShaderiv(vsh, GL_COMPILE_STATUS, &compilation_status);
    if(!compilation_status) {
      char compilation_log[512] = {0};
      glGetShaderInfoLog(vsh, sizeof(compilation_log), NULL, compilation_log);
      fprintf(stderr, "vertex shader compile error:\n%s\n", compilation_log);
      exit(1);
    }
  }

  GLuint fsh = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fsh, 1, &fsh_source, NULL);
  glCompileShader(fsh);
  {
    int compilation_status;
    glGetShaderiv(fsh, GL_COMPILE_STATUS, &compilation_status);
    if(!compilation_status) {
      char compilation_log[512] = {0};
      glGetShaderInfoLog(fsh, sizeof(compilation_log), NULL, compilation_log);
      fprintf(stderr, "fragment shader compile error:\n%s\n", compilation_log);
      exit(1);
    }
  }

  GLuint shader = glCreateProgram();
  glAttachShader(shader, vsh);
  glAttachShader(shader, fsh);
  glLinkProgram(shader);
  {
    int link_status;
    glGetProgramiv(shader, GL_LINK_STATUS, &link_status);
    if(!link_status) {
      char link_log[512] = {0};
      glGetProgramInfoLog(shader, sizeof(link_log), NULL, link_log);
      fprintf(stderr, "shader link error:\n%s\n", link_log);
      exit(1);
    }
  }

  glDeleteShader(vsh);
  glDeleteShader(fsh);

  return shader;
}

void gl_draw_rect(
    double x0, double y0, double x1, double y1,
    double tx0, double ty0, double tx1, double ty1) {
  glBegin(GL_TRIANGLE_STRIP);
  glTexCoord2f(tx0, ty0);
  glVertex3f(x0, y0, 0.0f);
  glTexCoord2f(tx1, ty0);
  glVertex3f(x1, y0, 0.0f);
  glTexCoord2f(tx0, ty1);
  glVertex3f(x0, y1, 0.0f);
  glTexCoord2f(tx1, ty1);
  glVertex3f(x1, y1, 0.0f);
  glEnd();
}
