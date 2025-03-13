#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int result = 0;
  int a1, a2, b1, b2;
  while (fscanf(file, "%d-%d,%d-%d ", &a1, &a2, &b1, &b2) != EOF) {
    if ((a1 >= b1 && a2 <= b2) || (b1 >= a1 && b2 <= a2)) {
      result++;
    }
  }

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int result = 0;
  int a1, a2, b1, b2;
  while (fscanf(file, "%d-%d,%d-%d ", &a1, &a2, &b1, &b2) != EOF) {
    if (!(a1 > b2 || b1 > a2)) {
      result++;
    }
  }

  printf("Part 2 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/04/example.txt");
  part1("2022/04/input.txt");
  part2("2022/04/example.txt");
  part2("2022/04/input.txt");
  return 0;
}