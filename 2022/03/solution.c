#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int result = 0;
  char line[200];
  while (fgets(line, sizeof(line), file)) {
    int length = strlen(line);
    if (line[length - 1] == '\n')
      length--;
    int half = length / 2;
    int counts[53] = {0};
    for (int i = 0; i < length; i++) {
      int priority = line[i] - 96;
      if (priority < 1)
        priority += 58;
      assert(priority > 0);
      assert(priority < 53);
      if (i < half) {
        counts[priority] += 1;
      } else {
        if (counts[priority] != 0) {
          result += priority;
          break;
        }
      }
    }
  }

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int result = 0;
  int rucksack = 0;
  char line[200];
  int counts[53] = {0};
  while (fgets(line, sizeof(line), file)) {
    if (rucksack == 0) {
      memset(counts, 0, sizeof counts);
    }
    int length = strlen(line);
    if (line[length - 1] == '\n')
      length--;
    for (int i = 0; i < length; i++) {
      int priority = line[i] - 96;
      if (priority < 1)
        priority += 58;
      assert(priority > 0);
      assert(priority < 53);

      if (counts[priority] == rucksack) {
        counts[priority] += 1;
      }
      if (rucksack == 2 && counts[priority] == 3) {
        result += priority;
        break;
      }
    }
    rucksack = (rucksack + 1) % 3;
  }

  printf("Part 2 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/03/example.txt");
  part1("2022/03/input.txt");
  part2("2022/03/example.txt");
  part2("2022/03/input.txt");
  return 0;
}