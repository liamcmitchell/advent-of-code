#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  time_t start = time(NULL);

  char input[11000];
  size_t length = fread(input, 1, sizeof input, file);
  input[length] = 0;
  int size = strchr(input, '\n') - input;
  int visible[11000] = {0};

  for (int x = 0; x < size; x++) {
    int max = -1;
    for (int y = 0; y < size; y++) {
      int index = x + y * (size + 1);
      int height = input[index] - '0';
      if (height > max) {
        max = height;
        visible[index] = 1;
      }
    }

    max = -1;
    for (int y = size - 1; y >= 0; y--) {
      int index = x + y * (size + 1);
      int height = input[index] - '0';
      if (height > max) {
        max = height;
        visible[index] = 1;
      }
    }
  }

  for (int y = 0; y < size; y++) {
    int max = -1;
    for (int x = 0; x < size; x++) {
      int index = x + y * (size + 1);
      int height = input[index] - '0';
      if (height > max) {
        max = height;
        visible[index] = 1;
      }
    }

    max = -1;
    for (int x = size - 1; x >= 0; x--) {
      int index = x + y * (size + 1);
      int height = input[index] - '0';
      if (height > max) {
        max = height;
        visible[index] = 1;
      }
    }
  }

  int result = 0;
  for (int i = 0; i < size * (size + 1); i++) {
    result += visible[i];
  }

  printf("Part 1 %s %d %.0lfms\n", name, result,
         difftime(time(NULL), start) / 1000);
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  time_t start = time(NULL);

  char input[11000];
  size_t length = fread(input, 1, sizeof input, file);
  input[length] = 0;
  int size = strchr(input, '\n') - input;
  int result = 0;

  for (int x = 0; x < size; x++) {
    for (int y = 0; y < size; y++) {
      int index = x + y * (size + 1);
      int height = input[index];
      int left = 0;
      for (int vx = x - 1; vx >= 0; vx--) {
        left++;
        if (input[vx + y * (size + 1)] >= height)
          break;
      }
      int right = 0;
      for (int vx = x + 1; vx < size; vx++) {
        right++;
        if (input[vx + y * (size + 1)] >= height)
          break;
      }
      int up = 0;
      for (int vy = y - 1; vy >= 0; vy--) {
        up++;
        if (input[x + vy * (size + 1)] >= height)
          break;
      }
      int down = 0;
      for (int vy = y + 1; vy < size; vy++) {
        down++;
        if (input[x + vy * (size + 1)] >= height)
          break;
      }
      int score = left * right * up * down;
      if (score > result) {
        result = score;
      }
    }
  }

  printf("Part 2 %s %d %.0lfms\n", name, result,
         difftime(time(NULL), start) / 1000);
}

int main(void) {
  part1("2022/08/example.txt");
  part1("2022/08/input.txt");
  part2("2022/08/example.txt");
  part2("2022/08/input.txt");
  return 0;
}