#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  char op;
  int operand;
  int time = 0;
  int values[300];
  int reg = 1;

  while (fscanf(file, "%c%*c%*c%*c %d ", &op, &operand) != EOF) {
    time++;
    values[time] = reg;
    if (op == 'a') {
      time++;
      values[time] = reg;
      reg += operand;
    }
  }

  int result = 0;
  for (int i = 20; i <= 220; i += 40) {
    result += values[i] * i;
  }

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  char op;
  int operand;
  int time = 0;
  int values[300];
  int reg = 1;

  while (fscanf(file, "%c%*c%*c%*c %d ", &op, &operand) != EOF) {
    time++;
    values[time] = reg;
    if (op == 'a') {
      time++;
      values[time] = reg;
      reg += operand;
    }
  }

  for (int y = 0; y < 6; y++) {
    for (int x = 0; x < 40; x++) {
      if (abs(values[1 + x + y * 40] - x) < 2) {
        printf("#");
      } else {
        printf(".");
      }
    }
    printf("\n");
  }

  printf("Part 2 %s %lums\n", name,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/10/example.txt");
  part1("2022/10/input.txt");
  part2("2022/10/example.txt");
  part2("2022/10/input.txt");
  return 0;
}