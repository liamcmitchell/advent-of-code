#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef unsigned char u8;
typedef signed char i8;
typedef unsigned short int u16;
typedef signed short int i16;
typedef unsigned long int u32;
typedef signed long int i32;
typedef signed long long int i64;

char* digits = "=-012";

i64 parse(char* snafu) {
  i64 result = 0;
  for (u8 i = 0; snafu[i] != 0; i++) {
    for (u8 j = 0; j < 5; j++) {
      if (snafu[i] == digits[j]) {
        result = result * 5 + j - 2;
      }
    }
  }
  return result;
}

char* serialize(i64 number, char* snafu) {
  u8 len = 0;
  while (number != 0) {
    i8 digit = ((number + 2) % 5) - 2;
    snafu[len] = digits[digit + 2];
    number = (number - digit) / 5;
    len++;
  }
  snafu[len] = 0;
  for (u8 i = 0; i < len / 2; i++) {
    char temp = snafu[i];
    snafu[i] = snafu[len - 1 - i];
    snafu[len - 1 - i] = temp;
  }
  return snafu;
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  i64 sum = 0;
  char buf[100];
  while (fgets(buf, sizeof buf, file) != NULL) {
    sum += parse(buf);
  }

  char result[100];
  serialize(sum, result);

  printf("Part 1 %s %s %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/25/example.txt");
  part1("2022/25/input.txt");
  // 🥳
  return 0;
}
