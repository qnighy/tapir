#include <stdio.h>
#include <ruby.h>

RUBY_GLOBAL_SETUP

static VALUE protected_main(VALUE data);

int main() {
  int ruby_argc = 2;
  char *ruby_argv_array[] = {
    (char*)"ruby",
    NULL
  };
  char **ruby_argv = ruby_argv_array;
  int state = 0;

  ruby_sysinit(&ruby_argc, &ruby_argv);
  {
    RUBY_INIT_STACK;
    ruby_init();
    rb_protect(protected_main, Qnil, &state);
  }
  return state;
}

static VALUE protected_main(VALUE data) {
  (void) data;

  rb_eval_string("print \"Hello, world!\\n\"");
  return Qnil;
}
