// Copyright 2017 Masaki Hara. See the COPYRIGHT
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "archive.h"
#include <stdlib.h>
#include <stdint.h>

#if RGSS == 3
#define RGSS_ARCHIVE_NAME "Game.rgss3a"
#elif RGSS == 2
#define RGSS_ARCHIVE_NAME "Game.rgss2a"
#else
#define RGSS_ARCHIVE_NAME "Game.rgssad"
#endif

struct Entry {
  uint32_t key;
  uint64_t pos;
  uint64_t size;
  char *filename;
};

struct EntryRW {
  const struct Entry *entry;
  uint32_t key;
  uint64_t pos;
};

static size_t entries_size = 0, entries_capa = 0;
static struct Entry *entries = NULL;

static int my_strcasecmp(const char *s1, const char *s2) {
  while(*s1 || *s2) {
    char c1 = *s1;
    char c2 = *s2;
    if('A' <= c1 && c1 <= 'Z') c1 |= 0x20;
    if('A' <= c2 && c2 <= 'Z') c2 |= 0x20;
    if(c1 != c2) return c1 < c2 ? -1 : 1;
    ++s1;
    ++s2;
  }
  return 0;
}

static int compare_entries(const void *o1, const void *o2) {
  const struct Entry *e1 = (const struct Entry *)o1;
  const struct Entry *e2 = (const struct Entry *)o2;
  return my_strcasecmp(e1->filename, e2->filename);
}

#if RGSS == 3
#define ARCHIVE_HEADER "RGSSAD\x00\x03"
#else
#define ARCHIVE_HEADER "RGSSAD\x00\x01"
#endif

static size_t readUint32(SDL_RWops *context, uint32_t *ptr, size_t nmemb) {
  size_t i;
  for(i = 0; i < nmemb; ++i) {
    char data[4];
    if(SDL_RWread(context, data, 4, 1) < 1) break;
    ptr[i] =
      (uint32_t)(unsigned char)data[0] |
      ((uint32_t)(unsigned char)data[1] << 8) |
      ((uint32_t)(unsigned char)data[2] << 16) |
      ((uint32_t)(unsigned char)data[3] << 24);
  }
  return i;
}

static SDL_RWops *archive;

void initArchive(void) {
  archive = SDL_RWFromFile(RGSS_ARCHIVE_NAME, "rb");
  if(!archive) return;

  int64_t archive_size = SDL_RWsize(archive);

  uint32_t archive_key;
  {
    char header[8];
    if(SDL_RWread(archive, header, 1, 8) < 8) goto broken;
    if(memcmp(header, ARCHIVE_HEADER, 8)) goto broken;
#if RGSS == 3
    if(readUint32(archive, &archive_key, 1) < 1) goto broken;
    archive_key = archive_key * 9 + 3;
#else
    archive_key = 0xDEADCAFE;
#endif
  }

  entries_capa = 200;
  entries = malloc(sizeof(*entries) * entries_capa);

  while(true) {
#if RGSS == 3
    uint32_t pos, size, entry_key, filename_size;
    if(readUint32(archive, &pos, 1) < 1) goto broken;
    pos ^= archive_key;
    if(pos == 0) break;
    if(readUint32(archive, &size, 1) < 1) goto broken;
    if(readUint32(archive, &entry_key, 1) < 1) goto broken;
    if(readUint32(archive, &filename_size, 1) < 1) goto broken;
    size ^= archive_key;
    entry_key ^= archive_key;
    filename_size ^= archive_key;
#else
    uint32_t filename_size;
    if(readUint32(archive, &filename_size, 1) < 1) break;
    filename_size ^= archive_key;
    archive_key = archive_key * 7 + 3;
#endif
    char *filename = malloc(filename_size + 1);
    filename[filename_size] = '\0';
    if(SDL_RWread(archive, filename, filename_size, 1) < 1) goto broken;
    for(size_t i = 0; i < filename_size; ++i) {
#if RGSS == 3
      filename[i] ^= archive_key >> ((i & 3) << 3);
#else
      filename[i] ^= archive_key;
      archive_key = archive_key * 7 + 3;
#endif
      if(filename[i] == '\\') filename[i] = '/';
    }
#if RGSS == 3
#else
    uint32_t size, entry_key;
    if(readUint32(archive, &size, 1) < 1) goto broken;
    size ^= archive_key;
    archive_key = archive_key * 7 + 3;
    uint64_t pos = SDL_RWtell(archive);
    if(pos == (uint64_t)(-1)) goto broken;
    if(SDL_RWseek(archive, size, RW_SEEK_CUR) < 0) goto broken;
    entry_key = archive_key;
#endif

    if((int64_t)pos + size > archive_size) goto broken;

    if(entries_size >= entries_capa) {
      entries_capa += entries_capa / 2;
      entries = realloc(entries, sizeof(*entries) * entries_capa);
    }
    entries[entries_size].pos = pos;
    entries[entries_size].size = size;
    entries[entries_size].key = entry_key;
    entries[entries_size].filename = filename;
    entries_size++;
    // fprintf(stderr, "%7d %6d %08X %s\n", pos, size, entry_key, filename);
  }

  qsort(entries, entries_size, sizeof(*entries), compare_entries);

  return;
broken:
  fprintf(stderr, "Tapir error: archive broken\n");
  exit(1);
}

void deinitArchive(void) {
  if(archive) {
    free(entries);
    entries_size = 0;
    entries_capa = 0;
    SDL_RWclose(archive);
  }
}

bool archiveExists(void) {
  return archive != NULL;
}

static Sint64 entry_size(SDL_RWops *context);
static Sint64 entry_seek(SDL_RWops *context, Sint64 offset, int whence);
static size_t entry_read(SDL_RWops *context, void *ptr, size_t size, size_t maxnum);
static size_t entry_write(SDL_RWops *context, const void *ptr, size_t size, size_t num);
static int entry_close(SDL_RWops *context);

SDL_RWops *openFromArchive(const char *path) {
  if(!archive) return NULL;

  struct Entry dummy_entry = { 0, 0, 0, (char*)path };
  const struct Entry *entry = bsearch(
      &dummy_entry, entries, entries_size, sizeof(*entries), compare_entries);
  if(!entry) return NULL;
  struct EntryRW *entry_rw = malloc(sizeof(*entry_rw));
  entry_rw->entry = entry;
  entry_rw->key = entry->key;
  entry_rw->pos = 0;
  if(SDL_RWseek(archive, entry->pos, RW_SEEK_SET) < 0) {
    fprintf(stderr, "Seeking in archive failed\n");
  }
  SDL_RWops *stream = SDL_AllocRW();
  stream->size = entry_size;
  stream->seek = entry_seek;
  stream->read = entry_read;
  stream->write = entry_write;
  stream->close = entry_close;
  stream->type = SDL_RWOPS_UNKNOWN;
  stream->hidden.unknown.data1 = entry_rw;
  return stream;
}

static Sint64 entry_size(SDL_RWops *context) {
  struct EntryRW *entry_rw = (struct EntryRW *)context->hidden.unknown.data1;
  return entry_rw->entry->size;
}
static Sint64 entry_seek(SDL_RWops *context, Sint64 offset, int whence) {
  struct EntryRW *entry_rw = (struct EntryRW *)context->hidden.unknown.data1;
  uint64_t old_pos = entry_rw->pos;
  uint64_t new_pos;
  if(whence == RW_SEEK_SET) {
    new_pos = offset;
  } else if(whence == RW_SEEK_CUR) {
    new_pos = old_pos + offset;
  } else {
    new_pos = entry_rw->entry->size + offset;
  }
  if((int64_t)new_pos < 0) new_pos = 0;
  if(new_pos > entry_rw->entry->size) {
    new_pos = entry_rw->entry->size;
  }
  // fprintf(stderr, "entry_seek(\"%s\", %d, %s) pos=%d -> %d\n", entry_rw->entry->filename, (int)offset, whence == RW_SEEK_SET ? "RW_SEEK_SET" : whence == RW_SEEK_CUR ? "RW_SEEK_CUR" : "RW_SEEK_END", (int)old_pos, (int)new_pos);
  if(old_pos == new_pos) return new_pos;
  if(SDL_RWseek(archive, entry_rw->entry->pos + new_pos, RW_SEEK_SET) < 0) {
    fprintf(stderr, "Seeking archive failed\n");
    return -1;
  }
  uint32_t a = 7, b = 3;
  entry_rw->key = entry_rw->entry->key;
  for(int i = 2; new_pos >> i; ++i) {
    if((new_pos >> i) & 1) {
      entry_rw->key = entry_rw->key * a + b;
    }
    b *= 1 + a;
    a *= a;
  }
  return entry_rw->pos = new_pos;
}
static size_t entry_read(SDL_RWops *context, void *ptr, size_t size, size_t maxnum) {
  struct EntryRW *entry_rw = (struct EntryRW *)context->hidden.unknown.data1;
  size_t num = (entry_rw->entry->size - entry_rw->pos) / size;
  if(num > maxnum) num = maxnum;
  num = SDL_RWread(archive, ptr, size, num);
  if(num == 0) return num;
  for(size_t i = 0; i < size * num; ++i) {
    ((unsigned char *)ptr)[i] ^= entry_rw->key >> ((entry_rw->pos & 3) << 3);
    entry_rw->pos++;
    if((entry_rw->pos & 3) == 0) {
      entry_rw->key = entry_rw->key * 7 + 3;
    }
  }
  // fprintf(stderr, "entry_read(\"%s\", _, %zu, %zu) -> ", entry_rw->entry->filename, size, maxnum);
  // for(size_t i = 0; i < size * num; ++i) {
  //   fprintf(stderr, "%02x ", ((unsigned char *)ptr)[i]);
  // }
  // fprintf(stderr, "\n");
  return num;
}
static size_t entry_write(SDL_RWops *context, const void *ptr, size_t size, size_t num) {
  (void) context;
  (void) ptr;
  (void) size;
  (void) num;
  SDL_SetError("Cannot write to archive");
  return 0;
}
static int entry_close(SDL_RWops *context) {
  struct EntryRW *entry_rw = (struct EntryRW *)context->hidden.unknown.data1;
  free(entry_rw);
  SDL_FreeRW(context);
  return 0;
}
