#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SIZE 4000

typedef signed char i8;
typedef unsigned char u8;
typedef signed int i16;
typedef unsigned int u16;
typedef signed long int i32;
typedef unsigned long int u32;

struct path {
  u16 pos;
  u16 steps;
};

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  char map[SIZE];
  size_t len = fread(map, sizeof(char), SIZE, file);
  u8 width = strchr(map, '\n') - map;
  i8 directions[4] = {-width - 1, 1, width + 1, -1};
  u16 startpos = strchr(map, 'S') - map;
  map[startpos] = 'a';
  u16 endpos = strchr(map, 'E') - map;
  map[endpos] = 'z';

  bool seen[SIZE] = {false};
  struct path queue[SIZE];
  u16 queuehead = 0;
  u16 queuetail = 0;

  seen[startpos] = true;
  queue[queuetail].pos = startpos;
  queue[queuetail].steps = 0;
  queuetail++;

  u32 result = 0;
  while (queuehead < queuetail) {
    u16 pos = queue[queuehead].pos;
    u16 steps = queue[queuehead].steps;
    char elevation = map[pos];

    for (u8 d = 0; d < 4; d++) {
      u16 nextpos = pos + directions[d];

      if (nextpos >= len)
        continue;

      char nextelevation = map[nextpos];

      if (nextelevation == '\n' || nextelevation - elevation > 1)
        continue;

      if (seen[nextpos])
        continue;
      seen[nextpos] = true;

      u16 nextsteps = steps + 1;

      if (nextpos == endpos) {
        result = nextsteps;
        goto done;
      }

      queue[queuetail].pos = nextpos;
      queue[queuetail].steps = nextsteps;
      queuetail++;
    }
    queuehead++;
    continue;

  done:
    break;
  }

  printf("Part 1 %s %lu %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  char map[SIZE];
  size_t len = fread(map, sizeof(char), SIZE, file);
  u8 width = strchr(map, '\n') - map;
  i8 directions[4] = {-width - 1, 1, width + 1, -1};
  u16 startpos = strchr(map, 'S') - map;
  map[startpos] = 'a';
  u16 endpos = strchr(map, 'E') - map;
  map[endpos] = 'z';

  bool seen[SIZE] = {false};
  struct path queue[SIZE];
  u16 queuehead = 0;
  u16 queuetail = 0;

  // Same as before but start at the end and look for the first 'a';
  seen[endpos] = true;
  queue[queuetail].pos = endpos;
  queue[queuetail].steps = 0;
  queuetail++;

  u32 result = 0;
  while (queuehead < queuetail) {
    u16 pos = queue[queuehead].pos;
    u16 steps = queue[queuehead].steps;
    char elevation = map[pos];

    for (u8 d = 0; d < 4; d++) {
      u16 nextpos = pos + directions[d];

      if (nextpos < 0 || nextpos >= len)
        continue;

      char nextelevation = map[nextpos];

      if (nextelevation == '\n' || nextelevation - elevation < -1) {
        continue;
      }

      if (seen[nextpos]) {
        continue;
      }
      seen[nextpos] = true;

      u16 nextsteps = steps + 1;

      if (nextelevation == 'a') {
        result = nextsteps;
        goto done;
      }

      queue[queuetail].pos = nextpos;
      queue[queuetail].steps = nextsteps;
      queuetail++;
    }
    queuehead++;
    continue;

  done:
    break;
  }

  printf("Part 2 %s %lu %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/12/example.txt");
  part1("2022/12/input.txt");
  part2("2022/12/example.txt");
  part2("2022/12/input.txt");
  return 0;
}