#define _BSD_SOURCE
#define _LARGEFILE64_SOURCE

#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stddef.h>
#include <inttypes.h>
#include <errno.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <linux/fs.h>
#include <linux/hdreg.h>
#include "disk.h"


#if 1
#include <stdio.h>
#define PERROR()				\
do {						\
printf("[!] %s, %u\n", __FILE__, __LINE__);	\
} while (0)
#else
#define PERROR()
#endif


/* generic raw disk based accesses */

#define DISK_BLOCK_SIZE 512

static const char* get_root_dev_name(char* s, size_t n)
{
  /* find the block device the root is mount on */

#if 0 /* iterative method */

  struct stat st_root;
  struct stat st_dent;
  char* p;
  int err = -1;
  DIR* dir;

  if (stat("/", &st_root)) goto on_error_0;

  dir = opendir("/dev");
  if (dir == NULL) goto on_error_0;

  strcpy(s, "/dev/");
  p = s + sizeof("/dev/") - 1;
  n -= sizeof("/dev/") - 1;

  while (err == -1)
  {
    struct dirent* const de = readdir(dir);

    if (de == NULL) break ;

    strncpy(p, de->d_name, n);
    p[n - 1] = 0;

    if (lstat(s, &st_dent)) continue ;

    if (S_ISBLK(st_dent.st_mode) == 0) continue ;

    if (major(st_dent.st_rdev) != major(st_root.st_dev)) continue ;
    if (minor(st_dent.st_rdev) != minor(st_root.st_dev)) continue ;

    err = 0;
  }

  closedir(dir);
 on_error_0:
  return err == -1 ? NULL : p;

#else /* fast method */

  const ssize_t res = readlink("/dev/root", s, n);
  if (res < 2) return NULL;
  /* skip pX partition suffix */
  s[res - 2] = 0;
  return s;

#endif /* iterative method */
}

static int get_chs_geom(int fd, size_t* chs, size_t sector_count)
{
  struct hd_geometry geom;

  if (ioctl(fd, HDIO_GETGEO, &geom))
  {
    geom.heads = 255;
    geom.sectors = 63;
    geom.cylinders = sector_count / (255 * 63);
  }

  chs[0] = (size_t)geom.cylinders;
  chs[1] = (size_t)geom.heads;
  chs[2] = (size_t)geom.sectors;

  return 0;
}

static int get_block_size(int fd, uint64_t* size)
{
  /* BLKPBSZGET */
  unsigned int tmp;
  if (ioctl(fd, BLKPBSZGET, &tmp)) return -1;
  *size = (uint64_t)tmp;
  return 0;
}

static int get_dev_size(int fd, uint64_t* size)
{
  /* BLKGETSIZE defined linux/fs.h */
  /* note: the size is returned in bytes / 512 */

  long arg;
  if (ioctl(fd, BLKGETSIZE, &arg)) return -1;
  *size = (uint64_t)arg;
  return 0;
}

static int read_size_t(int fd, uint64_t* x)
{
  char buf[32];
  const ssize_t n = read(fd, buf, sizeof(buf) - 1);

  if ((n <= 0) || (n == (sizeof(buf) - 1))) return -1;
  buf[n] = 0;
  *x = (uint64_t)atoll(buf);
  return 0;
}

static char* make_part_sysfs_path(const char* disk_name, size_t i)
{
  static char path[512];
  char buf[4];

  strcpy(path, "/sys/class/block/");
  strcat(path, disk_name);
  strcat(path, "p");
  buf[0] = '0' + i;
  buf[1] = 0;
  strcat(path, buf);

  return path;
}

static unsigned int does_part_exist(const char* name, size_t i)
{
  const char* const path = make_part_sysfs_path(name, i);
  struct stat st;
  return stat(path, &st) == 0;
}

static int get_part_off(const char* name, size_t i, uint64_t* off)
{
  /* offset returned in block size */

  char* path;
  int fd;
  int err;

  path = make_part_sysfs_path(name, i);
  strcat(path, "/start");

  fd = open(path, O_RDONLY);
  if (fd == -1) return -1;

  err = read_size_t(fd, off);
  close(fd);

  return err;
}

static int get_part_size(const char* name, size_t i, uint64_t* off)
{
  /* size returned in block size */

  char* path;
  int fd;
  int err;

  path = make_part_sysfs_path(name, i);
  strcat(path, "/size");

  fd = open(path, O_RDONLY);
  if (fd == -1) return -1;

  err = read_size_t(fd, off);
  close(fd);

  return err;
}

static const char* make_dev_path(const char* name)
{
  static char path[512];
  strcpy(path, "/dev/");
  strcat(path, name);
  return path;
}

int disk_open(disk_handle_t* disk, const char* dev_name)
{
  uint64_t dev_size;
  size_t i;

  disk->fd = open(make_dev_path(dev_name), O_RDWR | O_LARGEFILE);
  if (disk->fd == -1)
  {
    PERROR();
    goto on_error_0;
  }

  if (get_block_size(disk->fd, &disk->block_size))
  {
    PERROR();
    goto on_error_1;
  }

  /* it is assumed block_size == 512 */
  if (disk->block_size != DISK_BLOCK_SIZE)
  {
    PERROR();
    goto on_error_1;
  }

  /* note: the size is returned in bytes /512 */
  if (get_dev_size(disk->fd, &dev_size))
  {
    PERROR();
    goto on_error_1;
  }
  disk->block_count = (dev_size / disk->block_size) * 512;

  if (get_chs_geom(disk->fd, disk->chs, (size_t)disk->block_count))
  {
    PERROR();
    goto on_error_1;
  }

  for (i = 0; i < DISK_MAX_PART_COUNT; ++i)
  {
    const size_t part_id = i + 1;

    if (does_part_exist(dev_name, part_id) == 0) break ;

    if (get_part_off(dev_name, part_id, &disk->part_off[i]))
    {
      PERROR();
      goto on_error_1;
    }

    if (get_part_size(dev_name, part_id, &disk->part_size[i]))
    {
      PERROR();
      goto on_error_1;
    }
  }
  disk->part_count = i;

  /* success */
  return 0;

 on_error_1:
  close(disk->fd);
 on_error_0:
  return -1;
}

int disk_open_root(disk_handle_t* disk)
{
  char buf[256];
  if (get_root_dev_name(buf, sizeof(buf)) == NULL) return -1;
  return disk_open(disk, buf);
}

int disk_open_dev(disk_handle_t* disk, const char* name)
{
  return disk_open(disk, name);
}

void disk_close(disk_handle_t* disk)
{
  close(disk->fd);
}

int disk_seek(disk_handle_t* disk, size_t off)
{
  const off64_t off64 = (off64_t)off * (off64_t)disk->block_size;
  if (lseek64(disk->fd, off64, SEEK_SET) != off64) return -1;
  return 0;
}

int disk_write
(disk_handle_t* disk, size_t off, size_t size, const uint8_t* buf)
{
  /* assume size * disk->block_size does not overflow */
  if (disk_seek(disk, off) == -1) return -1;
  size *= disk->block_size;

  if (write(disk->fd, buf, size) != (ssize_t)size) return -1;
  return 0;
}

int disk_read
(disk_handle_t* disk, size_t off, size_t size, uint8_t* buf)
{
  /* assume size * disk->block_size does not overflow */
  if (disk_seek(disk, off) == -1) return -1;
  size *= disk->block_size;
  if (read(disk->fd, buf, size) != (ssize_t)size) return -1;
  return 0;
}

#if 0 /* dance configuration */

typedef struct conf_header
{
  /* stored in big endian format */
#define CONF_HEADER_MAGIC 0xda5cac5e
  uint32_t magic;
  /* total size, header included */
  uint32_t size;
  uint32_t vers;
} __attribute__((packed)) conf_header_t;

static uint32_t get_uint32_be(const uint8_t* buf)
{
  uint32_t x;

  x = ((uint32_t)buf[0]) << 24;
  x |= ((uint32_t)buf[1]) << 16;
  x |= ((uint32_t)buf[2]) << 8;
  x |= ((uint32_t)buf[3]) << 0;

  return x;
}

static size_t get_conf_size(const conf_header_t* h)
{
  return (size_t)get_uint32_be((const uint8_t*)&h->size);
}

static uint32_t get_conf_magic(const conf_header_t* h)
{
  return get_uint32_be((const uint8_t*)&h->magic);
}

static unsigned int is_conf_magic(const conf_header_t* h)
{
  return get_conf_magic(h) == CONF_HEADER_MAGIC;
}

#endif /* dance configuration */


/* mbr structures */
/* http://en.wikipedia.org/wiki/Master_boot_record */

typedef struct
{
  /* little endian encoding */
  uint8_t status;
  uint8_t first_chs[3];
  uint8_t type;
  uint8_t last_chs[3];
  uint32_t first_lba;
  uint32_t sector_count;
} __attribute__((packed)) mbe_t;

typedef struct
{
  uint8_t code[446];
#define MBR_ENTRY_COUNT 4
  mbe_t entries[MBR_ENTRY_COUNT];
#define MBR_MAGIC_00 0x55
#define MBR_MAGIC_01 0xaa
  uint8_t magic[2];
} __attribute__((packed)) mbr_t;

static unsigned int is_mbr_magic(const mbr_t* mbr)
{
  const uint8_t* const magic = mbr->magic;
  return (magic[0] == MBR_MAGIC_00) && (magic[1] == MBR_MAGIC_01);
}

static unsigned int is_mbe_active(const mbe_t* e)
{
  return e->status & (1 << 7);
}

static size_t find_active_mbe(const mbr_t* mbr)
{
  size_t i;

  for (i = 0; i != MBR_ENTRY_COUNT; ++i)
  {
    if (is_mbe_active(&mbr->entries[i])) break ;
  }

  return i;
}

static void put_uint32_le(uint8_t* buf, uint32_t x)
{
  buf[0] = (uint8_t)(x >> 0);
  buf[1] = (uint8_t)(x >> 8);
  buf[2] = (uint8_t)(x >> 16);
  buf[3] = (uint8_t)(x >> 24);
}

__attribute__((unused))
static uint32_t get_uint32_le(const uint8_t* buf)
{
  uint32_t x;

  x = ((uint32_t)buf[0]) << 0;
  x |= ((uint32_t)buf[1]) << 8;
  x |= ((uint32_t)buf[2]) << 16;
  x |= ((uint32_t)buf[3]) << 24;

  return x;
}

__attribute__((unused))
static size_t chs_to_lba
(const size_t* geom, const uint8_t* chs)
{
  /* http://en.wikipedia.org/wiki/Logical_block_addressing */

  const size_t hpc = geom[1];
  const size_t spt = geom[2];

  const size_t hi = (((size_t)chs[1]) << 2) & ~((1 << 8) - 1);
  const size_t c = (size_t)(hi | (size_t)chs[2]);
  const size_t h = (size_t)chs[0];
  const size_t s = (size_t)(chs[1] & ((1 << 6) - 1));

  const size_t lba = (c * hpc + h) * spt + s - 1;

  return lba;
}

static void lba_to_chs
(const size_t* geom, size_t lba, uint8_t* chs)
{
  const size_t hpc = geom[1];
  const size_t spt = geom[2];

  const size_t c = lba / (spt * hpc);
  const size_t h = (lba / spt) % hpc;
  const size_t s = (lba % spt) + 1;

  chs[0] = (uint8_t)h;
  chs[1] = (uint8_t)(s | ((c >> 2) & ~((1 << 6) - 1)));
  chs[2] = (uint8_t)c;
}

static int set_mbe_addr
(mbe_t* e, const size_t* chs, size_t off, size_t size)
{
  /* off and size in sectors */

  lba_to_chs(chs, off, e->first_chs);
  lba_to_chs(chs, off + size - 1, e->last_chs);

  put_uint32_le((uint8_t*)&e->first_lba, (uint32_t)off);
  put_uint32_le((uint8_t*)&e->sector_count, (uint32_t)size);

  return 0;
}

static int get_mbe_addr
(const mbe_t* e, const size_t* chs, size_t* off, size_t* size)
{
  /* off and size in sectors */

#if 0
  const size_t first_lba = (size_t)chs_to_lba(chs, e->first_chs);
  const size_t last_lba = (size_t)chs_to_lba(chs, e->last_chs);
  *off = first_lba;
  *size = 1 + last_lba - first_lba;
#else
  *off = (size_t)get_uint32_le((const uint8_t*)&e->first_lba);
  *size = (size_t)get_uint32_le((const uint8_t*)&e->sector_count);
#endif

  return 0;
}


/* disk update routines */
/* To increase the operation safety, a partition pivoting scheme */
/* is used: the whole disk is logically seen as 2 blocks of same */
/* size. At a current time, only one of these 2 blocks is used */
/* to store the system. When a disk update is requested, the tool */
/* selects the unused block and write the new image on it. once it */
/* is done, the tool update the disk MBR to point to the new */
/* partition. This last operation operation acts as a commit. */

int disk_update_with_mem(const uint8_t* buf, size_t size)
{
  /* size the buf size in bytes */

  static const size_t max_disk_size = UINT32_MAX / DISK_BLOCK_SIZE;
  static const size_t mbr_size = sizeof(mbr_t) / DISK_BLOCK_SIZE;

  disk_handle_t disk;
  int err = -1;
  mbr_t cur_mbr;
  mbr_t new_mbr;
  size_t disk_size;
  size_t cur_boot_pos;
  size_t new_boot_pos;
  size_t new_root_pos;
  size_t cur_boot_off;
  size_t cur_boot_size;
  size_t new_boot_off;
  size_t new_boot_size;
  size_t new_root_off;
  size_t new_root_size;
  size_t write_size;
  const uint8_t* new_root_buf;
  const uint8_t* new_boot_buf;

  if (size < sizeof(mbr_t))
  {
    PERROR();
    goto on_error_0;
  }

  memcpy(&new_mbr, buf, sizeof(mbr_t));

  if (is_mbr_magic(&new_mbr) == 0)
  {
    PERROR();
    goto on_error_0;
  }

#ifdef DISK_UNIT
  if (disk_open_dev(&disk, "mmcblk0"))
  /* if (disk_open_root(&disk)) */
#else
  if (disk_open_root(&disk))
#endif
  {
    PERROR();
    goto on_error_0;
  }

  /* get disk size, trunc to 4GB. */

  disk_size = disk.block_count;
  if (disk_size > max_disk_size) disk_size = max_disk_size;

  if (disk_read(&disk, 0, mbr_size, (uint8_t*)&cur_mbr))
  {
    PERROR();
    goto on_error_1;
  }

  if (is_mbr_magic(&cur_mbr) == 0)
  {
    PERROR();
    goto on_error_1;
  }

  /* find the current active partition (ie. boot) */
  cur_boot_pos = find_active_mbe(&cur_mbr);
  if (cur_boot_pos == MBR_ENTRY_COUNT)
  {
    PERROR();
    goto on_error_1;
  }

  /* find the new active partition (ie. boot) */
  new_boot_pos = find_active_mbe(&new_mbr);
  if (new_boot_pos >= (MBR_ENTRY_COUNT - 1))
  {
    PERROR();
    goto on_error_1;
  }
  new_root_pos = new_boot_pos + 1;

  /* get the new boot and root addresses */

  if (get_mbe_addr(&new_mbr.entries[new_boot_pos],
		   disk.chs,
		   &new_boot_off, &new_boot_size))
  {
    PERROR();
    goto on_error_1;
  }
  new_boot_buf = (uint8_t*)buf + new_boot_off * DISK_BLOCK_SIZE;

  if (get_mbe_addr(&new_mbr.entries[new_root_pos],
		   disk.chs,
		   &new_root_off, &new_root_size))
  {
    PERROR();
    goto on_error_1;
  }
  new_root_buf = (uint8_t*)buf + new_root_off * DISK_BLOCK_SIZE;

  /* if the current boot offset is less than disk_size / 2 */
  /* then use the second disk area for new partitions by */
  /* shifting them of disk_size / 2. */

  if (get_mbe_addr(&cur_mbr.entries[cur_boot_pos],
		   disk.chs,
		   &cur_boot_off, &cur_boot_size))
  {
    PERROR();
    goto on_error_1;
  }

  if (cur_boot_off < (disk_size / 2))
  {
    new_boot_off += disk_size / 2;
    new_root_off += disk_size / 2;
  }

  /* rewrite new boot and root entries */

  if (set_mbe_addr(&new_mbr.entries[new_boot_pos],
		   disk.chs,
		   new_boot_off, new_boot_size))
  {
    PERROR();
    goto on_error_1;
  }

  if (set_mbe_addr(&new_mbr.entries[new_root_pos],
		   disk.chs,
		   new_root_off, new_root_size))
  {
    PERROR();
    goto on_error_1;
  }

  /* write new boot and root to disk */
  /* an error or abort wont prevent the system to reboot */

  if (disk_write(&disk, new_boot_off, new_boot_size, new_boot_buf))
  {
    PERROR();
    goto on_error_1;
  }

  /* partition size may exceed file size */

  write_size = size - (new_root_buf - buf);
  if (write_size % DISK_BLOCK_SIZE) write_size += DISK_BLOCK_SIZE;
  write_size /= DISK_BLOCK_SIZE;
  if (write_size > new_root_size) write_size = new_root_size;

  if (disk_write(&disk, new_root_off, write_size, new_root_buf))
  {
    PERROR();
    goto on_error_1;
  }

#if 0 /* dance configuration */
  /* copy dance configuration */
  /* keep it centralized here */
  /* TODO: share conf_header_t with conf.h */
  /* TODO: more checks */
  {
    uint8_t* conf_buf;
    uint8_t one_block[DISK_BLOCK_SIZE];
    size_t cur_conf_off;
    size_t new_conf_off;
    size_t cur_root_off;
    size_t cur_root_size;
    size_t conf_size;
    int conf_err = -1;

    get_mbe_addr(&cur_mbr.entries[cur_boot_pos + 1],
		 disk.chs,
		 &cur_root_off, &cur_root_size);

    cur_conf_off = cur_root_off + cur_root_size;
    if (disk_read(&disk, cur_conf_off, 1, one_block))
    {
      conf_err = 0;
      goto on_conf_error_0;
    }

    if (is_conf_magic((const conf_header_t*)one_block) == 0)
    {
      conf_err = 0;
      goto on_conf_error_0;
    }

    conf_size = get_conf_size((const conf_header_t*)one_block);
    if (conf_size % DISK_BLOCK_SIZE) conf_size += DISK_BLOCK_SIZE;
    conf_size /= DISK_BLOCK_SIZE;
    conf_buf = malloc(conf_size * DISK_BLOCK_SIZE);
    if (conf_buf == NULL)
    {
      PERROR();
      goto on_conf_error_0;
    }
  
    if (disk_read(&disk, cur_conf_off, conf_size, conf_buf))
    {
      PERROR();
      goto on_conf_error_1;
    }

    new_conf_off = new_root_off + new_root_size;
    if (disk_write(&disk, new_conf_off, conf_size, conf_buf))
    {
      PERROR();
      goto on_conf_error_1;
    }

    conf_err = 0;

  on_conf_error_1:
    free(conf_buf);
  on_conf_error_0:
    if (conf_err) goto on_error_1;
  }
#endif /* copy dance configuration */

  /* write new mbr, commit the operation */
  /* an error may prevent the system to reboot */

  if (disk_write(&disk, 0, mbr_size, (const uint8_t*)&new_mbr))
  {
    PERROR();
    goto on_error_1;
  }

  err = 0;

 on_error_1:
  disk_close(&disk);
 on_error_0:
  return err;
}

int disk_update_with_file(const char* path)
{
  struct stat st;
  uint8_t* buf;
  size_t size;
  int fd;
  int err = -1;

  fd = open(path, O_RDONLY);
  if (fd == -1)
  {
    PERROR();
    goto on_error_0;
  }

  if (fstat(fd, &st))
  {
    PERROR();
    goto on_error_1;
  }

  size = st.st_size;
  buf = mmap(NULL, size, PROT_READ, MAP_SHARED, fd, 0);
  if (buf == (uint8_t*)MAP_FAILED)
  {
    PERROR();
    goto on_error_1;
  }
  
  err = disk_update_with_mem(buf, size);

  munmap(buf, size);
 on_error_1:
  close(fd);
 on_error_0:
  return err;
}


#ifdef DISK_UNIT

int main(int ac, char** av)
{
  return disk_update_with_file(av[1]);
}

#endif /* DISK_UNIT */
