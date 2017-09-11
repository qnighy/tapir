#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include "misc.h"

void tryChdir(const char *path) {
  if(chdir(path)) {
    fprintf(stderr, "cannot chdir: %s\n", strerror(errno));
  }
}
