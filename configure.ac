#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT(tapir, 0.0.1, ackie.h.gmai@gmail.com)
AC_CONFIG_SRCDIR([src/main.c])
AM_INIT_AUTOMAKE([foreign std-options])
AM_CONFIG_HEADER(src/config.h)

# Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET

# Checks for libraries.
PKG_CHECK_MODULES(SDL, [sdl2 SDL2_image SDL2_mixer SDL2_ttf])
PKG_CHECK_MODULES(GL, [gl])
PKG_CHECK_MODULES(FONTCONFIG, [fontconfig])
PKG_CHECK_MODULES(LIBCONFIG, [libconfig])

# Checks for header files.
AC_CHECK_HEADERS([limits.h stdint.h stdlib.h string.h strings.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_PROG_CC_C99
AC_CHECK_HEADER_STDBOOL
AC_TYPE_INT16_T
AC_TYPE_INT32_T
AC_TYPE_SIZE_T
AC_TYPE_SSIZE_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T

# Checks for library functions.
AC_FUNC_MALLOC
AC_FUNC_REALLOC
AC_CHECK_FUNCS([atexit realpath strchr strdup strerror strrchr strstr])

AC_CONFIG_FILES([Makefile
                 accordion/Makefile
                 launcher/Makefile
                 violin/Makefile
                 xylophone/Makefile
                 doc/man/tapir-a.1
                 doc/man/tapir-v.1
                 doc/man/tapir-x.1
                 doc/man/tapir.1])
AC_OUTPUT
