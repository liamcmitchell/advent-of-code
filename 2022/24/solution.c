#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MAPWIDTH 100
#define MAPHEIGHT 35
#define MAPSTATES 700
#define QUEUESIZE 10000

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

vec2 directions[5] = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}, {0, 0}};

struct map {
  u8 width;
  u8 height;
  bool blizzards[4][MAPWIDTH][MAPHEIGHT];
};

void parse(FILE* file, struct map* map) {
  i16 x = -1;
  i16 y = -1;
  int c;
  while ((c = fgetc(file)) != EOF) {
    if (c == '\n') {
      y++;
      x = -1;
      continue;
    }
    if (c == '^') {
      map->blizzards[1][x][y] = true;
    }
    if (c == 'v') {
      map->blizzards[0][x][y] = true;
    }
    if (c == '<') {
      map->blizzards[3][x][y] = true;
    }
    if (c == '>') {
      map->blizzards[2][x][y] = true;
    }
    x++;
  }
  map->width = x - 1;
  map->height = y;
}

void add(vec2* out, vec2* a, vec2* b) {
  out->x = a->x + b->x;
  out->y = a->y + b->y;
}

u16 fastest(struct map* map, vec2 start, vec2 end, u16 minutes) {
  // Not a simple BFS because the map is shifting.
  // We only mark a square seen for it's specific blizzard state.
  // LCM of 35 & 100 is 700, so 700 possible states.
  bool seen[MAPWIDTH][MAPHEIGHT][MAPSTATES] = {};

  struct path {
    u16 minutes;
    vec2 pos;
  };
  struct path queue[QUEUESIZE];
  u16 qh = 0;
  u16 qt = 0;

  queue[qt++] = (struct path){minutes, start};

  while (qh != qt) {
    struct path path = queue[qh];
    qh = (qh + 1) % QUEUESIZE;

    for (u8 d = 0; d < 5; d++) {
      struct path next = path;
      next.minutes++;
      add(&next.pos, &next.pos, &directions[d]);

      // Waiting at start, special case because it's outside the blizzard.
      if (next.pos.y == start.y && next.pos.x == start.x &&
          (next.minutes - minutes) < MAPSTATES) {
        queue[qt++] = next;
        continue;
      }

      if (next.pos.x == end.x && next.pos.y == end.y) {
        return next.minutes;
      }

      if (next.pos.x < 0 || next.pos.x >= map->width || next.pos.y < 0 ||
          next.pos.y >= map->height)
        continue;

      if (seen[next.pos.x][next.pos.y][next.minutes % MAPSTATES]) {
        continue;
      }
      seen[next.pos.x][next.pos.y][next.minutes % MAPSTATES] = true;

      for (u8 b = 0; b < 4; b++) {
        i16 bx = (next.pos.x + next.minutes * directions[b].x) % map->width;
        if (bx < 0)
          bx += map->width;
        i16 by = (next.pos.y + next.minutes * directions[b].y) % map->height;
        if (by < 0)
          by += map->height;
        if (map->blizzards[b][bx][by]) {
          goto next;
        }
      }

      queue[qt] = next;
      qt = (qt + 1) % QUEUESIZE;

      if (qt == qh) {
        printf("queue full\n");
        return -1;
      }

    next:
      continue;
    }
  }

  printf("finished without result\n");
  return -1;
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct map map = {};
  parse(file, &map);

  vec2 startpos = {0, -1};
  vec2 end = {map.width - 1, map.height};

  u16 result = fastest(&map, startpos, end, 0);

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct map map = {};
  parse(file, &map);

  vec2 startpos = {0, -1};
  vec2 end = {map.width - 1, map.height};

  u16 result = fastest(&map, startpos, end, 0);
  result = fastest(&map, end, startpos, result);
  result = fastest(&map, startpos, end, result);

  printf("Part 2 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/24/example.txt");
  part1("2022/24/input.txt");
  part2("2022/24/example.txt");
  part2("2022/24/input.txt");
  return 0;
}