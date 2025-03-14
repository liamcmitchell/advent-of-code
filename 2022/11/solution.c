#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

struct monkey {
  char op;
  int operand;
  int test;
  int true;
  int false;
  int itemcount;
  unsigned long int items[100];
};

int desc(const void* a, const void* b) {
  return (*(int*)b - *(int*)a);
}

int gcd(int a, int b) {
  if (b == 0)
    return a;
  return gcd(b, a % b);
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct monkey monkeys[8];
  int monkeycount = 0;

  while (1) {
    struct monkey* monkey = &monkeys[monkeycount];
    fscanf(file, "Monkey %*d: ");
    fscanf(file, " Starting items: ");
    char buf[100];
    fgets(buf, sizeof buf, file);
    char* item = strtok(buf, ", ");
    monkey->itemcount = 0;
    while (item) {
      monkey->items[monkey->itemcount] = atoi(item);
      monkey->itemcount++;
      item = strtok(NULL, ", ");
    }
    fscanf(file, " Operation: new = old %c ", &monkey->op);
    fgets(buf, sizeof buf, file);
    if (buf[0] == 'o') {
      monkey->op = '2';
      monkey->operand = 0;
    } else {
      monkey->operand = atoi(buf);
    }
    fscanf(file, " Test: divisible by %d ", &monkey->test);
    fscanf(file, " If true: throw to monkey %d ", &monkey->true);
    fscanf(file, " If false: throw to monkey %d ", &monkey->false);

    monkeycount++;

    if (fgets(buf, sizeof buf, file) == NULL)
      break;
  }

  int inspectcount[8] = {0};
  for (int r = 0; r < 20; r++) {
    for (int m = 0; m < monkeycount; m++) {
      struct monkey* monkey = &monkeys[m];
      for (int i = 0; i < monkey->itemcount; i++) {
        int worry = monkey->items[i];
        if (monkey->op == '2') {
          worry = worry * worry;
        } else if (monkey->op == '*') {
          worry = worry * monkey->operand;
        } else {
          worry = worry + monkey->operand;
        }
        worry = worry / 3;
        struct monkey* next;
        if (worry % monkey->test == 0) {
          next = &monkeys[monkey->true];
        } else {
          next = &monkeys[monkey->false];
        }
        next->items[next->itemcount] = worry;
        next->itemcount++;
      }
      inspectcount[m] += monkey->itemcount;
      monkey->itemcount = 0;
    }
  }

  qsort(inspectcount, monkeycount, sizeof(inspectcount[0]), desc);

  int result = inspectcount[0] * inspectcount[1];

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct monkey monkeys[8];
  int monkeycount = 0;

  while (1) {
    struct monkey* monkey = &monkeys[monkeycount];
    fscanf(file, "Monkey %*d: ");
    fscanf(file, " Starting items: ");
    char buf[100];
    fgets(buf, sizeof buf, file);
    char* item = strtok(buf, ", ");
    monkey->itemcount = 0;
    while (item) {
      monkey->items[monkey->itemcount] = atoi(item);
      monkey->itemcount++;
      item = strtok(NULL, ", ");
    }
    fscanf(file, " Operation: new = old %c ", &monkey->op);
    fgets(buf, sizeof buf, file);
    if (buf[0] == 'o') {
      monkey->op = '2';
      monkey->operand = 1;
    } else {
      monkey->operand = atoi(buf);
    }
    fscanf(file, " Test: divisible by %d ", &monkey->test);
    fscanf(file, " If true: throw to monkey %d ", &monkey->true);
    fscanf(file, " If false: throw to monkey %d ", &monkey->false);

    monkeycount++;

    if (fgets(buf, sizeof buf, file) == NULL)
      break;
  }

  int lcm = 1;
  for (int m = 0; m < monkeycount; m++) {
    lcm = lcm * (monkeys[m].test / gcd(lcm, monkeys[m].test));
  }

  unsigned long int inspectcount[8] = {0};
  for (int r = 0; r < 10000; r++) {
    for (int m = 0; m < monkeycount; m++) {
      struct monkey* monkey = &monkeys[m];
      for (int i = 0; i < monkey->itemcount; i++) {
        unsigned long int worry = monkey->items[i];
        if (monkey->op == '2') {
          worry = worry * worry;
        } else if (monkey->op == '*') {
          worry = worry * monkey->operand;
        } else {
          worry = worry + monkey->operand;
        }
        worry = worry % lcm;
        struct monkey* next;
        if (worry % monkey->test == 0) {
          next = &monkeys[monkey->true];
        } else {
          next = &monkeys[monkey->false];
        }
        next->items[next->itemcount] = worry;
        next->itemcount++;
      }
      inspectcount[m] += monkey->itemcount;
      monkey->itemcount = 0;
    }
  }

  qsort(inspectcount, monkeycount, sizeof(inspectcount[0]), desc);

  unsigned long int result = inspectcount[0] * inspectcount[1];

  printf("Part 2 %s %lu %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/11/example.txt");
  part1("2022/11/input.txt");
  part2("2022/11/example.txt");
  part2("2022/11/input.txt");
  return 0;
}