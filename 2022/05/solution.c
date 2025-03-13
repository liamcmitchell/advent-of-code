#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int stacks;
  int counts[10] = {0};
  char crates[10][100];
  char line[100];
  while (fgets(line, sizeof(line), file)) {
    int length = strlen(line);
    stacks = length / 4;

    if (isdigit(line[1])) {
      // Finished parsing stacks, skip next line.
      fgets(line, sizeof(line), file);
      break;
    }

    for (int i = 0; i < stacks; i++) {
      char crate = line[i * 4 + 1];
      if (isalpha(crate)) {
        crates[i][counts[i]] = crate;
        counts[i]++;
      }
    }
  }

  // Reverse stacks.
  for (int i = 0; i < stacks; i++) {
    int count = counts[i];
    for (int j = 0; j < count / 2; j++) {
      int k = count - j - 1;
      char temp = crates[i][j];
      crates[i][j] = crates[i][k];
      crates[i][k] = temp;
    }
  }

  int move, from, to;
  while (fscanf(file, "move %d from %d to %d ", &move, &from, &to) != EOF) {
    from--;
    to--;
    for (int i = 0; i < move; i++) {
      crates[to][counts[to]] = crates[from][counts[from] - 1];
      counts[to]++;
      counts[from]--;
    }
  }

  char result[10] = {'\0'};
  for (int i = 0; i < stacks; i++) {
    result[i] = crates[i][counts[i] - 1];
  }

  printf("Part 1 %s %s %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  int stacks;
  int counts[10] = {0};
  char crates[10][100];
  char line[100];
  while (fgets(line, sizeof(line), file)) {
    int length = strlen(line);
    stacks = length / 4;

    if (isdigit(line[1])) {
      // Finished parsing stacks, skip next line.
      fgets(line, sizeof(line), file);
      break;
    }

    for (int i = 0; i < stacks; i++) {
      char crate = line[i * 4 + 1];
      if (isalpha(crate)) {
        crates[i][counts[i]] = crate;
        counts[i]++;
      }
    }
  }

  // Reverse stacks.
  for (int i = 0; i < stacks; i++) {
    int count = counts[i];
    for (int j = 0; j < count / 2; j++) {
      int k = count - j - 1;
      char temp = crates[i][j];
      crates[i][j] = crates[i][k];
      crates[i][k] = temp;
    }
  }

  int move, from, to;
  while (fscanf(file, "move %d from %d to %d ", &move, &from, &to) != EOF) {
    from--;
    to--;
    memcpy(&crates[to][counts[to]], &crates[from][counts[from] - move],
           sizeof crates[0][0] * move);
    counts[to] += move;
    counts[from] -= move;
  }

  char result[10] = {'\0'};
  for (int i = 0; i < stacks; i++) {
    result[i] = crates[i][counts[i] - 1];
  }

  printf("Part 2 %s %s %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/05/example.txt");
  part1("2022/05/input.txt");
  part2("2022/05/example.txt");
  part2("2022/05/input.txt");
  return 0;
}