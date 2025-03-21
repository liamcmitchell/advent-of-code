#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SIZE 24

typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;

typedef bool grid[SIZE][SIZE][SIZE];

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  grid grid = {{{false}}};
  u8 x, y, z;
  while (fscanf(file, " %hhd,%hhd,%hhd ", &x, &y, &z) != EOF) {
    grid[x + 1][y + 1][z + 1] = true;
  }

  u16 result = 0;

  for (x = 1; x < SIZE - 1; x++) {
    for (y = 1; y < SIZE - 1; y++) {
      for (z = 1; z < SIZE - 1; z++) {
        if (!grid[x][y][z])
          continue;

        result += !grid[x - 1][y][z];
        result += !grid[x + 1][y][z];
        result += !grid[x][y - 1][z];
        result += !grid[x][y + 1][z];
        result += !grid[x][y][z - 1];
        result += !grid[x][y][z + 1];
      }
    }
  }

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

struct pos {
  u8 x, y, z;
};

void expand(u8 x, u8 y, u8 z, grid lava, grid gas, struct pos* queue, u16* qt) {
  if (x >= SIZE || y >= SIZE || z >= SIZE || gas[x][y][z] || lava[x][y][z])
    return;

  gas[x][y][z] = true;
  queue[*qt].x = x;
  queue[*qt].y = y;
  queue[*qt].z = z;
  *qt += 1;
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  grid lava = {{{false}}};
  u8 x, y, z;
  while (fscanf(file, " %hhd,%hhd,%hhd ", &x, &y, &z) != EOF) {
    lava[x + 1][y + 1][z + 1] = true;
  }

  grid gas = {{{false}}};
  gas[0][0][0] = true;
  struct pos queue[15000] = {{0, 0, 0}};
  u16 qh = 0;
  u16 qt = 1;
  while (qh < qt) {
    x = queue[qh].x;
    y = queue[qh].y;
    z = queue[qh].z;
    qh++;
    expand(x - 1, y, z, lava, gas, queue, &qt);
    expand(x + 1, y, z, lava, gas, queue, &qt);
    expand(x, y - 1, z, lava, gas, queue, &qt);
    expand(x, y + 1, z, lava, gas, queue, &qt);
    expand(x, y, z - 1, lava, gas, queue, &qt);
    expand(x, y, z + 1, lava, gas, queue, &qt);
  }

  u16 result = 0;

  for (x = 1; x < SIZE - 1; x++) {
    for (y = 1; y < SIZE - 1; y++) {
      for (z = 1; z < SIZE - 1; z++) {
        if (!lava[x][y][z])
          continue;

        result += gas[x - 1][y][z];
        result += gas[x + 1][y][z];
        result += gas[x][y - 1][z];
        result += gas[x][y + 1][z];
        result += gas[x][y][z - 1];
        result += gas[x][y][z + 1];
      }
    }
  }

  printf("Part 2 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/18/example.txt");
  part1("2022/18/input.txt");
  part2("2022/18/example.txt");
  part2("2022/18/input.txt");
  return 0;
}