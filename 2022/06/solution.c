#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int result = 0;
  char buffer[5000] = {'\0'};
  fgets(buffer, sizeof buffer, file);
  int length = strlen(buffer);

  for (int i = 3; i < length; i++) {
    for (int j = 0; j < 3; j++) {
      for (int k = j + 1; k < 4; k++) {
        if (buffer[i - j] == buffer[i - k]) {
          goto next;
        }
      }
    }
    result = i + 1;
    break;

  next:
    continue;
  }

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int result = 0;
  char buffer[5000] = {'\0'};
  fgets(buffer, sizeof buffer, file);
  int length = strlen(buffer);

  for (int i = 13; i < length; i++) {
    for (int j = 0; j < 13; j++) {
      for (int k = j + 1; k < 14; k++) {
        if (buffer[i - j] == buffer[i - k]) {
          goto next;
        }
      }
    }
    result = i + 1;
    break;

  next:
    continue;
  }

  printf("Part 2 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/06/example.txt");
  part1("2022/06/input.txt");
  part2("2022/06/example.txt");
  part2("2022/06/input.txt");
  return 0;
}