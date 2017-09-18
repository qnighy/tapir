#include <SDL.h>
#define GL_GLEXT_PROTOTYPES
#include <SDL_opengl.h>
#include <SDL_opengl_glext.h>
#include "Window.h"
#include "Bitmap.h"
#include "Viewport.h"
#include "Rect.h"
#include "Color.h"
#include "Tone.h"
#include "misc.h"

static GLuint shader;

static void window_mark(struct Window *ptr);
static void window_free(struct Window *ptr);
static VALUE window_alloc(VALUE klass);

static VALUE rb_window_m_initialize(int argc, VALUE *argv, VALUE self);
static VALUE rb_window_m_initialize_copy(VALUE self, VALUE orig);
static VALUE rb_window_m_x(VALUE self);
static VALUE rb_window_m_set_x(VALUE self, VALUE newval);
static VALUE rb_window_m_y(VALUE self);
static VALUE rb_window_m_set_y(VALUE self, VALUE newval);
static VALUE rb_window_m_width(VALUE self);
static VALUE rb_window_m_set_width(VALUE self, VALUE newval);
static VALUE rb_window_m_height(VALUE self);
static VALUE rb_window_m_set_height(VALUE self, VALUE newval);
static VALUE rb_window_m_z(VALUE self);
static VALUE rb_window_m_set_z(VALUE self, VALUE newval);

static void renderWindow(struct Renderable *renderable);

VALUE rb_cWindow;

/*
 * A graphic object containing a bitmap.
 */
void Init_Window(void) {
  rb_cWindow = rb_define_class("Window", rb_cObject);
  rb_define_alloc_func(rb_cWindow, window_alloc);
  rb_define_private_method(rb_cWindow, "initialize",
      rb_window_m_initialize, -1);
  rb_define_private_method(rb_cWindow, "initialize_copy",
      rb_window_m_initialize_copy, 1);
  rb_define_method(rb_cWindow, "x", rb_window_m_x, 0);
  rb_define_method(rb_cWindow, "x=", rb_window_m_set_x, 1);
  rb_define_method(rb_cWindow, "y", rb_window_m_y, 0);
  rb_define_method(rb_cWindow, "y=", rb_window_m_set_y, 1);
  rb_define_method(rb_cWindow, "width", rb_window_m_width, 0);
  rb_define_method(rb_cWindow, "width=", rb_window_m_set_width, 1);
  rb_define_method(rb_cWindow, "height", rb_window_m_height, 0);
  rb_define_method(rb_cWindow, "height=", rb_window_m_set_height, 1);
  rb_define_method(rb_cWindow, "z", rb_window_m_z, 0);
  rb_define_method(rb_cWindow, "z=", rb_window_m_set_z, 1);
  // TODO: implement Window#dispose
  // TODO: implement Window#disposed?
  // TODO: implement Window#update
  // TODO: implement Window#move
  // TODO: implement Window#open?
  // TODO: implement Window#close?
  // TODO: implement Window#windowskin, Window#windowskin=
  // TODO: implement Window#contents
  // TODO: implement Window#cursor_rect
  // TODO: implement Window#viewport
  // TODO: implement Window#active
  // TODO: implement Window#visible
  // TODO: implement Window#arrows_visible
  // TODO: implement Window#pause
  // TODO: implement Window#x
  // TODO: implement Window#y
  // TODO: implement Window#width
  // TODO: implement Window#height
  // TODO: implement Window#z
  // TODO: implement Window#ox
  // TODO: implement Window#oy
  // TODO: implement Window#padding
  // TODO: implement Window#padding_bottom
  // TODO: implement Window#opacity
  // TODO: implement Window#back_opacity
  // TODO: implement Window#contents_opacity
  // TODO: implement Window#openness
  // TODO: implement Window#tone
}

bool isWindow(VALUE obj) {
  if(TYPE(obj) != T_DATA) return false;
  return RDATA(obj)->dmark == (void(*)(void*))window_mark;
}

struct Window *convertWindow(VALUE obj) {
  Check_Type(obj, T_DATA);
  // Note: original RGSS doesn't check types.
  if(RDATA(obj)->dmark != (void(*)(void*))window_mark) {
    rb_raise(rb_eTypeError,
        "can't convert %s into Window",
        rb_class2name(rb_obj_class(obj)));
  }
  struct Window *ret;
  Data_Get_Struct(obj, struct Window, ret);
  return ret;
}

void rb_window_modify(VALUE obj) {
  // Note: original RGSS doesn't check frozen.
  if(OBJ_FROZEN(obj)) rb_error_frozen("Window");
}

static void window_mark(struct Window *ptr) {
  rb_gc_mark(ptr->renderable.viewport);
}

static void window_free(struct Window *ptr) {
  unregisterRenderable(&ptr->renderable);
  xfree(ptr);
}

static VALUE window_alloc(VALUE klass) {
  struct Window *ptr = ALLOC(struct Window);
  ptr->renderable.render = renderWindow;
#if RGSS == 3
  ptr->renderable.z = 100;
#else
  ptr->renderable.z = 0;
#endif
  ptr->renderable.viewport = Qnil;
  ptr->x = 0;
  ptr->y = 0;
  ptr->width = 0;
  ptr->height = 0;
  registerRenderable(&ptr->renderable);
  VALUE ret = Data_Wrap_Struct(klass, window_mark, window_free, ptr);
  return ret;
}

/*
 * call-seq:
 *   Window.new
 *   Window.new(x)
 *   Window.new(x, y)
 *   Window.new(x, y, width)
 *   Window.new(x, y, width, height)
 *
 * Creates a new window.
 */
static VALUE rb_window_m_initialize(int argc, VALUE *argv, VALUE self) {
  struct Window *ptr = convertWindow(self);
  if(argc > 4) {
    rb_raise(rb_eArgError,
        "wrong number of arguments (%d for 4)", argc);
  }
  ptr->x = argc > 0 ? NUM2INT(argv[0]) : 0;
  ptr->y = argc > 1 ? NUM2INT(argv[1]) : 0;
  ptr->width = argc > 2 ? NUM2INT(argv[2]) : 0;
  ptr->height = argc > 3 ? NUM2INT(argv[3]) : 0;
  return Qnil;
}

static VALUE rb_window_m_initialize_copy(VALUE self, VALUE orig) {
  struct Window *ptr = convertWindow(self);
  struct Window *orig_ptr = convertWindow(orig);
  ptr->renderable.z = orig_ptr->renderable.z;
  ptr->renderable.viewport = orig_ptr->renderable.viewport;
  ptr->x = orig_ptr->x;
  ptr->y = orig_ptr->y;
  ptr->width = orig_ptr->width;
  ptr->height = orig_ptr->height;
  return Qnil;
}

static VALUE rb_window_m_x(VALUE self) {
  struct Window *ptr = convertWindow(self);
  return INT2NUM(ptr->x);
}

static VALUE rb_window_m_set_x(VALUE self, VALUE newval) {
  struct Window *ptr = convertWindow(self);
  rb_window_modify(self);
  ptr->x = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_y(VALUE self) {
  struct Window *ptr = convertWindow(self);
  return INT2NUM(ptr->y);
}

static VALUE rb_window_m_set_y(VALUE self, VALUE newval) {
  struct Window *ptr = convertWindow(self);
  rb_window_modify(self);
  ptr->y = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_width(VALUE self) {
  struct Window *ptr = convertWindow(self);
  return INT2NUM(ptr->width);
}

static VALUE rb_window_m_set_width(VALUE self, VALUE newval) {
  struct Window *ptr = convertWindow(self);
  rb_window_modify(self);
  ptr->width = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_height(VALUE self) {
  struct Window *ptr = convertWindow(self);
  return INT2NUM(ptr->height);
}

static VALUE rb_window_m_set_height(VALUE self, VALUE newval) {
  struct Window *ptr = convertWindow(self);
  rb_window_modify(self);
  ptr->height = NUM2INT(newval);
  return newval;
}

static VALUE rb_window_m_z(VALUE self) {
  struct Window *ptr = convertWindow(self);
  return INT2NUM(ptr->renderable.z);
}

static VALUE rb_window_m_set_z(VALUE self, VALUE newval) {
  struct Window *ptr = convertWindow(self);
  rb_window_modify(self);
  ptr->renderable.z = NUM2INT(newval);
  return newval;
}

static void renderWindow(struct Renderable *renderable) {
  struct Window *ptr = (struct Window *)renderable;
  // if(ptr->bitmap == Qnil) return;
  // struct Bitmap *bitmap_ptr = convertBitmap(ptr->bitmap);
  // SDL_Surface *surface = bitmap_ptr->surface;
  // struct Rect *src_rect = convertRect(ptr->src_rect);

  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  // // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  // // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  // GLfloat vertices[][3] = {
  //   {-1.0f, -1.0f, 0.0f},
  //   { 1.0f, -1.0f, 0.0f},
  //   {-1.0f,  1.0f, 0.0f},
  //   { 1.0f,  1.0f, 0.0f}
  // };

  // glEnable(GL_BLEND);
  // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  // glUseProgram(shader);
  // glUniform1i(glGetUniformLocation(shader, "tex"), 0);
  // glUniform2f(glGetUniformLocation(shader, "dst_size"),
  //     window_width, window_height);
  // glUniform2f(glGetUniformLocation(shader, "src_size"),
  //     surface->w, surface->h);
  // glUniform2f(glGetUniformLocation(shader, "src_topleft"),
  //     src_rect->x, src_rect->y);
  // glUniform2f(glGetUniformLocation(shader, "src_bottomright"),
  //     src_rect->x + src_rect->width, src_rect->y + src_rect->height);
  // glUniform2f(glGetUniformLocation(shader, "dst_translate"),
  //     ptr->x, ptr->y);
  // glUniform2f(glGetUniformLocation(shader, "src_translate"),
  //     ptr->ox, ptr->oy);
  // glUniform2f(glGetUniformLocation(shader, "zoom"),
  //     ptr->zoom_x, ptr->zoom_y);

  // glActiveTexture(GL_TEXTURE0);
  // bitmapBindTexture(bitmap_ptr);

  // glBegin(GL_TRIANGLE_STRIP);
  // for(size_t i = 0; i < sizeof(vertices)/sizeof(*vertices); ++i) {
  //   glVertex3fv(vertices[i]);
  // }
  // glEnd();

  // glUseProgram(0);
}

void initWindowSDL() {
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
    "uniform sampler2D tex;\n"
    "uniform vec2 dst_size;\n"
    "uniform vec2 dst_translate;\n"
    "uniform vec2 src_translate;\n"
    "uniform vec2 src_topleft;\n"
    "uniform vec2 src_bottomright;\n"
    "uniform vec2 src_size;\n"
    "uniform vec2 zoom;\n"
    // "uniform float angle;\n"
    // "uniform vec4 sprite_color;\n"
    // "uniform vec4 sprite_tone;\n"
    "\n"
    "void main(void) {\n"
    "    vec2 coord = vec2(gl_FragCoord.x, dst_size.y - gl_FragCoord.y);\n"
    "    coord = coord - dst_translate;\n"
    "    coord = vec2(coord.x / zoom.x, coord.y / zoom.y);\n"
    "    coord = coord + src_translate;\n"
    "    if(src_topleft.x <= coord.x && src_topleft.y <= coord.y && coord.x <= src_bottomright.x && coord.y <= src_bottomright.y) {\n"
    "      vec4 color = texture2D(tex, vec2(coord.x / src_size.x, coord.y / src_size.y));\n"
    "      gl_FragColor = color;\n"
    "    } else {\n"
    "      gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);\n"
    "    }\n"
    "}\n";

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

  shader = glCreateProgram();
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
}

void deinitWindowSDL() {
  glDeleteProgram(shader);
}
