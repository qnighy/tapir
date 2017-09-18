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
      fprintf(stderr, "vsh compile error:\n%s\n", compilation_log);
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
      fprintf(stderr, "fsh compile error:\n%s\n", compilation_log);
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
    }
  }

  glDeleteShader(vsh);
  glDeleteShader(fsh);

  return shader;
}
