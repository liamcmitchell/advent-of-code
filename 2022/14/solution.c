#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef unsigned char u8;
typedef unsigned long int u32;

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  bool map[120000] = {false};
  u32 width = 600;
  u32 height = 200;

  char buf[300];
  while (fgets(buf, sizeof buf, file) != NULL) {
    char* num = strtok(buf, ", ->");
    u32 x1 = atol(num);
    u32 y1 = atol(strtok(NULL, ", ->"));
    num = strtok(NULL, ", ->");
    while (num) {
      u32 x2 = atol(num);
      u32 y2 = atol(strtok(NULL, ", ->"));
      char dx = (x2 > x1) - (x2 < x1);
      char dy = (y2 > y1) - (y2 < y1);
      u32 x = x1;
      u32 y = y1;
      while (1) {
        map[x + y * width] = true;
        if (x == x2 && y == y2) {
          break;
        }
        x += dx;
        y += dy;
      }
      num = strtok(NULL, ", ->");
      x1 = x2;
      y1 = y2;
    }
  }

  u32 result = 0;
  u32 sx = 500;
  u32 sy = 0;
  while (sy < height) {
    if (!map[sx + (sy + 1) * width]) {
      sy++;
    } else if (!map[(sx - 1) + (sy + 1) * width]) {
      sx--;
      sy++;
    } else if (!map[(sx + 1) + (sy + 1) * width]) {
      sx++;
      sy++;
    } else {
      map[sx + sy * width] = true;
      result++;
      sx = 500;
      sy = 0;
    }
  }

  printf("Part 1 %s %lu %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  bool map[240000] = {false};
  u32 width = 1200;
  u32 maxheight;

  char buf[300];
  while (fgets(buf, sizeof buf, file) != NULL) {
    char* num = strtok(buf, ", ->");
    u32 x1 = atol(num);
    u32 y1 = atol(strtok(NULL, ", ->"));
    if (y1 > maxheight) {
      maxheight = y1;
    }
    num = strtok(NULL, ", ->");
    while (num) {
      u32 x2 = atol(num);
      u32 y2 = atol(strtok(NULL, ", ->"));
      if (y2 > maxheight) {
        maxheight = y2;
      }
      char dx = (x2 > x1) - (x2 < x1);
      char dy = (y2 > y1) - (y2 < y1);
      u32 x = x1;
      u32 y = y1;
      while (1) {
        map[x + y * width] = true;
        if (x == x2 && y == y2) {
          break;
        }
        x += dx;
        y += dy;
      }
      num = strtok(NULL, ", ->");
      x1 = x2;
      y1 = y2;
    }
  }

  // Draw floor.
  for (u32 x = 0; x < width; x++) {
    map[x + (maxheight + 2) * width] = true;
  }

  u32 result = 0;
  u32 sx = 500;
  u32 sy = 0;
  while (1) {
    if (!map[sx + (sy + 1) * width]) {
      sy++;
    } else if (!map[(sx - 1) + (sy + 1) * width]) {
      sx--;
      sy++;
    } else if (!map[(sx + 1) + (sy + 1) * width]) {
      sx++;
      sy++;
    } else if (sx == 500 && sy == 0) {
      result++;
      break;
    } else {
      map[sx + sy * width] = true;
      result++;
      sx = 500;
      sy = 0;
    }
  }

  printf("Part 2 %s %lu %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/14/example.txt");
  part1("2022/14/input.txt");
  part2("2022/14/example.txt");
  part2("2022/14/input.txt");
  return 0;
}