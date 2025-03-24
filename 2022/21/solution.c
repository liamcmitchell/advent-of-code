#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SIZE 3000

typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;

struct monkey {
  char name[5];
  char op;
  u32 a;
  u32 b;
};

struct monkeys {
  struct monkey items[SIZE];
  u16 len;
};

u16 monkeyi(const char* name, struct monkeys* monkeys) {
  for (u16 i = 0; i < monkeys->len; i++) {
    if (strcmp(monkeys->items[i].name, name) == 0) {
      return i;
    }
  }
  strcpy(monkeys->items[monkeys->len].name, name);
  monkeys->len++;
  return monkeys->len - 1;
}

void parse(FILE* file, struct monkeys* monkeys) {
  char buf[100];
  while (fgets(buf, sizeof buf, file) != NULL) {
    char* part = strtok(buf, ": \n");
    struct monkey* monkey = &monkeys->items[monkeyi(part, monkeys)];
    part = strtok(NULL, ": \n");
    if (isdigit(part[0])) {
      monkey->op = ':';
      monkey->a = atol(part);
    } else {
      monkey->a = monkeyi(part, monkeys);
      part = strtok(NULL, ": \n");
      monkey->op = part[0];
      part = strtok(NULL, ": \n");
      monkey->b = monkeyi(part, monkeys);
    }
  }
}

u32 resolve(u16 m, struct monkeys* monkeys) {
  struct monkey* monkey = &monkeys->items[m];

  if (monkey->op == ':')
    return monkey->a;

  u32 a = resolve(monkey->a, monkeys);
  u32 b = resolve(monkey->b, monkeys);

  if (a == 0 || b == 0) {
    return 0;
  }

  if (monkey->op == '+')
    return a + b;
  if (monkey->op == '-')
    return a - b;
  if (monkey->op == '*')
    return a * b;
  if (monkey->op == '/')
    return a / b;

  printf("unexpected op %c %hhd", monkey->op, monkey->op);
  return 0;
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct monkeys monkeys;
  monkeys.len = 0;
  parse(file, &monkeys);

  u32 result = resolve(monkeyi("root", &monkeys), &monkeys);

  printf("Part 1 %s %ld %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

u32 solve(u16 m, u32 value, struct monkeys* monkeys) {
  struct monkey* monkey = &monkeys->items[m];

  if (monkey->op == ':' && monkey->a == 0)
    return value;

  u32 a = resolve(monkey->a, monkeys);
  u32 b = resolve(monkey->b, monkeys);

  if (monkey->op == '=') {
    if (a == 0)
      return solve(monkey->a, b, monkeys);
    else
      return solve(monkey->b, a, monkeys);
  }
  if (monkey->op == '+') {
    if (a == 0) {
      return solve(monkey->a, value - b, monkeys);
    } else {
      return solve(monkey->b, value - a, monkeys);
    }
  }
  if (monkey->op == '-') {
    if (a == 0)
      return solve(monkey->a, value + b, monkeys);
    else
      return solve(monkey->b, a - value, monkeys);
  }
  if (monkey->op == '*') {
    if (a == 0)
      return solve(monkey->a, value / b, monkeys);
    else
      return solve(monkey->b, value / a, monkeys);
  }
  if (monkey->op == '/') {
    if (a == 0) {
      return solve(monkey->a, value * b, monkeys);
    } else {
      return solve(monkey->b, a / value, monkeys);
    }
  }

  printf("unexpected op %c %hhd", monkey->op, monkey->op);
  return 0;
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct monkeys monkeys;
  monkeys.len = 0;
  parse(file, &monkeys);

  monkeys.items[monkeyi("humn", &monkeys)].a = 0;
  monkeys.items[monkeyi("root", &monkeys)].op = '=';

  u32 result = solve(monkeyi("root", &monkeys), 0, &monkeys);

  printf("Part 2 %s %ld %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/21/example.txt");
  part1("2022/21/input.txt");
  part2("2022/21/example.txt");
  part2("2022/21/input.txt");
  return 0;
}