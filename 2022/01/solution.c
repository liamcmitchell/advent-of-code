#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  time_t start = time(NULL);
  char line[100];
  int result = 0;
  int current = 0;
  int calories;
  while (1) {
    char* res = fgets(line, sizeof(line), file);
    if (res == NULL || line[0] == '\n') {
      if (current > result)
        result = current;
      current = 0;
      if (res == NULL)
        break;
    } else {
      sscanf(line, "%d", &calories);
      current += calories;
    }
  }

  printf("Part 1 %s %d %.0lfms\n", name, result,
         difftime(time(NULL), start) / 1000);
}

int desc(const void* a, const void* b) {
  return (*(int*)b - *(int*)a);
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  time_t start = time(NULL);
  char line[100];
  int totals[300];
  int count = 0;
  int current = 0;
  int calories;
  while (1) {
    char* res = fgets(line, sizeof(line), file);
    if (res == NULL || line[0] == '\n') {
      totals[count] = current;
      count++;
      current = 0;
      if (res == NULL)
        break;
    } else {
      sscanf(line, "%d", &calories);
      current += calories;
    }
  }

  qsort(totals, count, sizeof(totals[0]), desc);
  int result = totals[0] + totals[1] + totals[2];

  printf("Part 2 %s %d %.0lfms\n", name, result,
         difftime(time(NULL), start) / 1000);
}

int main(void) {
  part1("2022/01/example.txt");
  part1("2022/01/input.txt");
  part2("2022/01/example.txt");
  part2("2022/01/input.txt");
  return 0;
}