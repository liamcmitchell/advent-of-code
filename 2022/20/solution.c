#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SIZE 5001

typedef unsigned char u8;
typedef unsigned short int u16;
typedef signed short int i16;
typedef unsigned long int u32;
typedef signed long long int i64;

struct number {
  i64 value;
  i64 pos;
};

u16 parse(FILE* file, struct number* numbers) {
  u16 count = 0;

  while (fscanf(file, " %lld ", &numbers[count].value) != EOF) {
    numbers[count].pos = count;
    count++;
  }

  return count;
}

i64 wrap(i64 pos, u16 count) {
  i64 res = pos % count;
  if (res < 0)
    res += count;
  return res;
}

void mix(struct number* numbers, u16 count) {
  for (u16 i = 0; i < count; i++) {
    i64 from = numbers[i].pos;
    i64 to = wrap(from + numbers[i].value, count - 1);
    if (from < to) {
      // Number moves right, numbers between shift left.
      for (u16 j = 0; j < count; j++) {
        if (numbers[j].pos > from && numbers[j].pos <= to) {
          numbers[j].pos--;
        }
      }
      numbers[i].pos = to;
    }
    if (from > to) {
      for (u16 j = 0; j < count; j++) {
        // Number moves left, numbers between shift right.
        if (numbers[j].pos < from && numbers[j].pos >= to) {
          numbers[j].pos++;
        }
      }
      numbers[i].pos = to;
    }
  }
}

i64 sumcoordinates(struct number* numbers, u16 count) {
  i64 zeropos = 0;
  for (u16 i = 0; i < count; i++) {
    if (numbers[i].value == 0) {
      zeropos = numbers[i].pos;
      break;
    }
  }

  i64 result = 0;
  for (u16 i = 0; i < count; i++) {
    i64 fromzero = wrap(numbers[i].pos - zeropos, count);
    if ((fromzero == wrap(1000, count)) || (fromzero == wrap(2000, count)) ||
        (fromzero == wrap(3000, count))) {
      result += numbers[i].value;
    }
  }

  return result;
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct number numbers[SIZE];
  u16 count = parse(file, numbers);

  mix(numbers, count);

  i64 result = sumcoordinates(numbers, count);

  printf("Part 1 %s %lld %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct number numbers[SIZE];
  u16 count = parse(file, numbers);

  for (u16 i = 0; i < count; i++) {
    numbers[i].value *= 811589153;
  }

  for (u16 i = 0; i < 10; i++) {
    mix(numbers, count);
  }

  i64 result = sumcoordinates(numbers, count);

  printf("Part 2 %s %lld %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/20/example.txt");
  part1("2022/20/input.txt");
  part2("2022/20/example.txt");
  part2("2022/20/input.txt");
  return 0;
}