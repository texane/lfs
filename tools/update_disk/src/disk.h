#ifndef DISK_H_INCLUDED
#define DISK_H_INCLUDED


#include <stdint.h>
#include <sys/types.h>


typedef struct disk_handle
{
  /* WARNING: 64 bit types to avoid overflow with large files */

  int fd;

  uint64_t block_size;
  uint64_t block_count;

  size_t chs[3];

  /* off, size in blocks */
#define DISK_MAX_PART_COUNT 4
  uint64_t part_count;
  uint64_t part_off[DISK_MAX_PART_COUNT];
  uint64_t part_size[DISK_MAX_PART_COUNT];

} disk_handle_t;


int disk_open(disk_handle_t*, const char*);
int disk_open_root(disk_handle_t*);
int disk_open_dev(disk_handle_t*, const char*);
void disk_close(disk_handle_t*);
int disk_seek(disk_handle_t*, size_t);
int disk_write(disk_handle_t*, size_t, size_t, const uint8_t*);
int disk_read(disk_handle_t*, size_t, size_t, uint8_t*);
int disk_update_with_mem(const uint8_t*, size_t);
int disk_update_with_file(const char*);


#endif /* DISK_H_INCLUDED */
