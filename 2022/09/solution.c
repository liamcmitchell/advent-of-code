#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int size = 1000;
  int visited[1000000] = {0};
  int hx = 500;
  int hy = 500;
  int tx = 500;
  int ty = 500;
  char direction;
  int steps;
  while (fscanf(file, "%c %d ", &direction, &steps) != EOF) {
    while (steps > 0) {
      steps--;
      switch (direction) {
        case 'U':
          hy--;
          break;
        case 'R':
          hx++;
          break;
        case 'D':
          hy++;
          break;
        case 'L':
          hx--;
          break;
      }
      int dx = hx - tx;
      int dy = hy - ty;
      if (abs(dx) > 1 || abs(dy) > 1) {
        if (dx > 0)
          tx++;
        if (dx < 0)
          tx--;
        if (dy > 0)
          ty++;
        if (dy < 0)
          ty--;
      }
      visited[tx + ty * size] = 1;
    }
  }

  int result = 0;
  for (int i = 0; i < size * size; i++) {
    result += visited[i];
  }

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

struct pos {
  int x;
  int y;
};

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int size = 1000;
  int visited[1000000] = {0};
  struct pos rope[10];
  for (int i = 0; i < 10; i++) {
    rope[i] = (struct pos){500, 500};
  }

  char direction;
  int steps;
  while (fscanf(file, "%c %d ", &direction, &steps) != EOF) {
    while (steps > 0) {
      steps--;
      switch (direction) {
        case 'U':
          rope[0].y--;
          break;
        case 'R':
          rope[0].x++;
          break;
        case 'D':
          rope[0].y++;
          break;
        case 'L':
          rope[0].x--;
          break;
      }
      for (int i = 1; i < 10; i++) {
        int dx = rope[i - 1].x - rope[i].x;
        int dy = rope[i - 1].y - rope[i].y;
        if (abs(dx) > 1 || abs(dy) > 1) {
          if (dx > 0)
            rope[i].x++;
          if (dx < 0)
            rope[i].x--;
          if (dy > 0)
            rope[i].y++;
          if (dy < 0)
            rope[i].y--;
        }
      }
      visited[rope[9].x + rope[9].y * size] = 1;
    }
  }

  int result = 0;
  for (int i = 0; i < size * size; i++) {
    result += visited[i];
  }

  printf("Part 2 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/09/example.txt");
  part1("2022/09/input.txt");
  part2("2022/09/example.txt");
  part2("2022/09/input.txt");
  return 0;
}