#ifndef TABLE_H
#define TABLE_H

#include <stdbool.h>
#include <stdint.h>
#include <ruby.h>

extern VALUE rb_cTable;
extern void Init_Table(void);

struct Table {
  int32_t dim, xsize, ysize, zsize, size;
  int16_t *data;
};

bool isTable(VALUE obj);
struct Table *convertTable(VALUE obj);
void rb_table_modify(VALUE obj);

VALUE rb_table_new(
    int32_t dim, int32_t xsize, int32_t ysize, int32_t zsize);
void rb_table_resize(
    VALUE self, int32_t new_dim, int32_t new_xsize,
    int32_t new_ysize, int32_t new_zsize);
int32_t rb_table_dim(VALUE self);
int32_t rb_table_xsize(VALUE self);
int32_t rb_table_ysize(VALUE self);
int32_t rb_table_zsize(VALUE self);
int16_t rb_table_aref(VALUE self, int32_t x, int32_t y, int32_t z);
void rb_table_aset(
    VALUE self, int32_t x, int32_t y, int32_t z, int16_t val);
int16_t *rb_table_data(VALUE self);

#endif /* TABLE_H */
