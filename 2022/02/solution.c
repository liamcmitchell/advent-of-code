#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  time_t start = time(NULL);

  int result = 0;
  char theirHand;
  char ourHand;
  while (fscanf(file, "%c %c ", &theirHand, &ourHand) > 0) {
    theirHand -= 'A';
    ourHand -= 'X';
    int score = (((ourHand - theirHand) + 4) % 3) * 3;
    result += score + ourHand + 1;
  }

  printf("Part 1 %s %d %.0lfms\n", name, result,
         difftime(time(NULL), start) / 1000);
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  time_t start = time(NULL);

  int result = 0;
  char theirHand;
  char expectedResult;
  while (fscanf(file, "%c %c ", &theirHand, &expectedResult) > 0) {
    theirHand -= 'A';
    expectedResult -= 'X';
    int ourHand = (theirHand + expectedResult + 2) % 3;
    int score = expectedResult * 3;
    result += score + ourHand + 1;
  }

  printf("Part 2 %s %d %.0lfms\n", name, result,
         difftime(time(NULL), start) / 1000);
}

int main(void) {
  part1("2022/02/example.txt");
  part1("2022/02/input.txt");
  part2("2022/02/example.txt");
  part2("2022/02/input.txt");
  return 0;
}