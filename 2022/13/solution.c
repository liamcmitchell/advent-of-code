#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef unsigned char u8;
typedef unsigned long int u32;

typedef char packet[256];

int asc(const void* a, const void* b) {
  packet* left = (packet*)a;
  packet* right = (packet*)b;

  u8 lefti = 0;
  u8 righti = 0;
  u8 leftwrapped = 0;
  u8 rightwrapped = 0;

  while (1) {
    char l = (*left)[lefti];
    char r = (*right)[righti];

    if (rightwrapped && !isdigit(r)) {
      // Left should be ending.
      if (l == ']') {
        lefti++;
        rightwrapped--;
        continue;
      } else {
        return 1;
      }
    }

    if (leftwrapped && !isdigit(l)) {
      // Right should be ending.
      if (r == ']') {
        righti++;
        leftwrapped--;
        continue;
      } else {
        return -1;
      }
    }

    if (l == r) {
      lefti++;
      righti++;
      continue;
    }

    if (isdigit(l) && isdigit(r)) {
      // Extra logic to check for 10s.
      if ((l < r && (*left)[lefti + 1] != '0') ||
          ((*right)[righti + 1] == '0')) {
        return -1;
      } else {
        return 1;
      }
    }

    if (l == ']') {
      return -1;
      break;
    }

    if (r == ']') {
      return 1;
    }

    if (l == '[' && isdigit(r)) {
      lefti++;
      rightwrapped++;
      continue;
    }

    if (r == '[' && isdigit(l)) {
      righti++;
      leftwrapped++;
      continue;
    }

    if (l == '0') {
      // Left was a 10, right was a 1.
      return 1;
    }

    if (r == '0') {
      // Right was a 10, left was a 1.
      return -1;
    }

    printf("unexpected case at %d:%c,%d:%c\n", lefti, l, righti, r);
    break;
  }

  return 0;
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  packet left;
  packet right;
  u8 pair = 0;
  u32 result = 0;

  while (1) {
    pair++;
    fgets(left, sizeof left, file);
    fgets(right, sizeof right, file);

    if (asc(left, right) < 0) {
      result += pair;
    }

    if (fgets(left, sizeof left, file) == NULL) {
      break;
    }
  }

  printf("Part 1 %s %lu %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  packet packets[302] = {"[[2]]", "[[6]]"};
  u32 packetcount = 2;

  while (1) {
    fgets(packets[packetcount++], sizeof(packet), file);
    fgets(packets[packetcount++], sizeof(packet), file);
    if (fgets(packets[packetcount], sizeof(packet), file) == NULL) {
      break;
    }
  }

  qsort(packets, packetcount, sizeof packets[0], asc);

  u32 result = 0;
  for (size_t i = 0; i < packetcount; i++) {
    if (strcmp(packets[i], "[[2]]") == 0) {
      result = i + 1;
    }
    if (strcmp(packets[i], "[[6]]") == 0) {
      result = result * (i + 1);
      break;
    }
  }

  printf("Part 2 %s %lu %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/13/example.txt");
  part1("2022/13/input.txt");
  part2("2022/13/example.txt");
  part2("2022/13/input.txt");
  return 0;
}