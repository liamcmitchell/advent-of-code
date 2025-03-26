#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MAPSIZE 202
#define PATHSIZE 6000

typedef unsigned char u8;
typedef signed char i8;
typedef unsigned short int u16;
typedef signed short int i16;
typedef unsigned long int u32;

struct vec2 {
  i16 x;
  i16 y;
};
typedef struct vec2 vec2;

enum tile { EDGE, OPEN, WALL };

typedef enum tile map[MAPSIZE][MAPSIZE];
typedef char path[PATHSIZE];

u8 parse(FILE* file, map map, path path) {
  char mapbuf[MAPSIZE];
  u8 size = 0;
  u8 y = 1;
  while (fgets(mapbuf, sizeof mapbuf, file) != NULL) {
    if (strlen(mapbuf) == 1) {
      break;
    }

    for (u8 i = 0; i < MAPSIZE; i++) {
      switch (mapbuf[i]) {
        case ' ':
          break;

        case '.':
          map[i + 1][y] = OPEN;
          break;

        case '#':
          map[i + 1][y] = WALL;
          break;

        default:
          if (size < i) {
            size = i;
          }
          y++;
          goto next;
      }
    }

  next:
    continue;
  }

  fgets(path, PATHSIZE, file);

  if (size < y - 1) {
    size = y - 1;
  }

  return size / 4;
}

void add(vec2* out, vec2* a, vec2* b) {
  out->x = a->x + b->x;
  out->y = a->y + b->y;
}

void rotate(vec2* out, i8 dir) {
  i16 x = out->x;
  out->x = -out->y * dir;
  out->y = x * dir;
}

void wrap1(vec2* nextpos, vec2* nextdir, map map, u8 size) {
  (void)(size);
  vec2 reverse = {-nextdir->x, -nextdir->y};
  while (1) {
    add(nextpos, nextpos, &reverse);
    if (map[nextpos->x][nextpos->y] == EDGE) {
      add(nextpos, nextpos, nextdir);
      break;
    }
  }
}

struct vec3 {
  i16 x;
  i16 y;
  i16 z;
};
typedef struct vec3 vec3;

void rotatex(vec3* out, i8 dir) {
  i16 y = out->y;
  out->y = -out->z * dir;
  out->z = y * dir;
}

void rotatey(vec3* out, i8 dir) {
  i16 x = out->x;
  out->x = -out->z * dir;
  out->z = x * dir;
}

// Index of face, special handling for rounding under 0.
i16 facei(i16 i, u8 size) {
  return (i - 1) / size - (i <= 0);
}

// Position relative to center of face.
// To get center between two ints we need to double.
i16 faceposi(i16 i, i16 boardpos, u8 size) {
  return (i - 1 - (boardpos * size)) * 2 - (size - 1);
}

// Reverse the above two transforms.
i16 facetopos(i16 face, i16 facepos, u8 size) {
  return 1 + face * size + (facepos + (size - 1)) / 2;
}

struct face {
  vec2 boardpos;
  vec3 facepos;
  vec3 facedir;
};

void moveface(struct face* face, vec2* dir) {
  add(&face->boardpos, &face->boardpos, dir);
  if (dir->x == 0) {
    rotatex(&face->facepos, dir->y);
    rotatex(&face->facedir, dir->y);
  } else {
    rotatey(&face->facepos, dir->x);
    rotatey(&face->facedir, dir->x);
  }
}

vec2 directions[4] = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}};

void wrap2(vec2* nextpos, vec2* nextdir, map map, u8 size) {
  bool seen[6][6] = {};
  struct face queue[6];
  u8 qh = 0;
  u8 qt = 0;

  vec2 boardpos = {facei(nextpos->x, size), facei(nextpos->y, size)};
  vec3 facepos = {faceposi(nextpos->x, boardpos.x, size),
                  faceposi(nextpos->y, boardpos.y, size), 0};
  vec3 facedir = {nextdir->x, nextdir->y, 99};

  struct face face = {boardpos, facepos, facedir};

  // Go back over edge to last face.
  vec2 reverse = {-nextdir->x, -nextdir->y};
  moveface(&face, &reverse);

  seen[boardpos.x][boardpos.y] = true;
  queue[qt++] = face;

  while (qh < qt) {
    struct face* face = &queue[qh++];

    for (u8 i = 0; i < 4; i++) {
      struct face next = *face;
      moveface(&next, &directions[i]);

      if (next.boardpos.x < 0 || next.boardpos.y < 0)
        continue;

      if (map[next.boardpos.x * size + 1][next.boardpos.y * size + 1] == EDGE)
        continue;

      if (seen[next.boardpos.x][next.boardpos.y])
        continue;
      seen[next.boardpos.x][next.boardpos.y] = true;

      if (next.facedir.z == 99) {
        nextpos->x = facetopos(next.boardpos.x, next.facepos.x, size);
        nextpos->y = facetopos(next.boardpos.y, next.facepos.y, size);
        nextdir->x = next.facedir.x;
        nextdir->y = next.facedir.y;
        return;
      }

      queue[qt++] = next;
    }
  }
}

void part(u8 number, const char* name, void (*wrap)(vec2*, vec2*, map, u8)) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  map map = {{}};
  path path;
  u8 size = parse(file, map, path);

  vec2 pos = {1, 1};
  vec2 dir = {1, 0};
  while (map[pos.x][pos.y] != OPEN) {
    add(&pos, &pos, &dir);
  }

  u8 dist = 0;
  for (u16 i = 0; i < PATHSIZE; i++) {
    if (isdigit(path[i])) {
      dist = dist * 10 + (path[i] - '0');
    } else {
      while (dist--) {
        vec2 nextpos;
        add(&nextpos, &pos, &dir);
        vec2 nextdir = {dir.x, dir.y};

        if (map[nextpos.x][nextpos.y] == EDGE) {
          (*wrap)(&nextpos, &nextdir, map, size);
        }

        if (map[nextpos.x][nextpos.y] == WALL) {
          break;
        }

        pos = nextpos;
        dir = nextdir;
      }
      dist = 0;
    }

    if (path[i] == 'R') {
      rotate(&dir, 1);
    }

    if (path[i] == 'L') {
      rotate(&dir, -1);
    }

    if (path[i] == 0) {
      break;
    }
  }

  u32 result = pos.y * 1000 + pos.x * 4;
  if (dir.y > 0)
    result += 1;
  if (dir.x < 0)
    result += 2;
  if (dir.y < 0)
    result += 3;

  printf("Part %hhd %s %ld %lums\n", number, name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part(1, "2022/22/example.txt", wrap1);
  part(1, "2022/22/input.txt", wrap1);
  part(2, "2022/22/example.txt", wrap2);
  part(2, "2022/22/input.txt", wrap2);
  return 0;
}