#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SIZE 3000

typedef unsigned char u8;
typedef signed char i8;
typedef unsigned short int u16;
typedef signed short int i16;
typedef unsigned long int u32;

struct vec2 {
  i16 x;
  i16 y;
};
typedef struct vec2 vec2;

u16 parse(FILE* file, vec2* elves) {
  u16 elfcount = 0;
  i16 x = 0;
  i16 y = 0;
  int c;
  while ((c = fgetc(file)) != EOF) {
    if (c == '\n') {
      y++;
      x = 0;
      continue;
    }

    if (c == '#') {
      elves[elfcount++] = (vec2){x, y};
    }
    x++;
  }
  return elfcount;
}

void add(vec2* out, vec2* a, vec2* b) {
  out->x = a->x + b->x;
  out->y = a->y + b->y;
}

struct direction {
  u8 mask;
  u8 oppmask;
  vec2 vec;
};

struct direction directions[4] = {{1, 2, {0, -1}},
                                  {2, 1, {0, 1}},
                                  {4, 8, {-1, 0}},
                                  {8, 4, {1, 0}}};

int compelfy(const void* a, const void* b) {
  vec2* elfa = (vec2*)a;
  vec2* elfb = (vec2*)b;
  return elfa->y - elfb->y;
}

struct proposal {
  u16 elf;
  vec2 pos;
  bool blocked;
};

int compproposaly(const void* a, const void* b) {
  struct proposal* pa = (struct proposal*)a;
  struct proposal* pb = (struct proposal*)b;
  return pa->pos.y - pb->pos.y;
}

u16 move(vec2* elves, u16 elfcount, u8 round) {
  qsort(elves, elfcount, sizeof elves[0], compelfy);

  u8 blocked[SIZE] = {};
  for (u16 i = 0; i < elfcount; i++) {
    for (u16 j = i + 1; j < elfcount; j++) {
      i16 dx = elves[j].x - elves[i].x;
      i16 dy = elves[j].y - elves[i].y;

      if (dy > 1) {
        break;
      }

      if (abs(dx) <= 1 && abs(dy) <= 1) {
        for (u8 d = 0; d < 4; d++) {
          if ((dx != 0 && dx == directions[d].vec.x) ||
              (dy != 0 && dy == directions[d].vec.y)) {
            blocked[i] |= directions[d].mask;
            blocked[j] |= directions[d].oppmask;
          }
        }
      }
    }
  }

  struct proposal proposals[SIZE] = {};
  u16 proposalcount = 0;
  for (u16 i = 0; i < elfcount; i++) {
    if (blocked[i] == 0 || blocked[i] == 15) {
      continue;
    }
    for (u8 d = 0; d < 4; d++) {
      u8 dd = ((d + round) % 4);
      if (blocked[i] & directions[dd].mask) {
        continue;
      }
      vec2 nextpos;
      add(&nextpos, &elves[i], &directions[dd].vec);
      proposals[proposalcount++] = (struct proposal){i, nextpos, false};
      break;
    }
  }

  qsort(proposals, proposalcount, sizeof proposals[0], compproposaly);

  for (u16 p = 0; p < proposalcount; p++) {
    if (proposals[p].blocked) {
      continue;
    }
    // Check ahead for identical proposals.
    for (u16 p2 = p + 1; p2 < proposalcount; p2++) {
      if (proposals[p2].pos.y > proposals[p].pos.y)
        break;
      if (proposals[p2].pos.x == proposals[p].pos.x) {
        proposals[p].blocked = true;
        proposals[p2].blocked = true;
      }
    }
    if (proposals[p].blocked) {
      continue;
    }
    elves[proposals[p].elf] = proposals[p].pos;
  }

  return proposalcount;
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  vec2 elves[SIZE];
  u16 elfcount = parse(file, elves);

  for (u8 round = 0; round < 10; round++) {
    move(elves, elfcount, round);
  }

  vec2 min = {};
  vec2 max = {};
  for (u16 i = 0; i < elfcount; i++) {
    if (elves[i].x < min.x)
      min.x = elves[i].x;
    if (elves[i].x > max.x)
      max.x = elves[i].x;
    if (elves[i].y < min.y)
      min.y = elves[i].y;
    if (elves[i].y > max.y)
      max.y = elves[i].y;
  }

  u32 result = (max.x - min.x + 1) * (max.y - min.y + 1) - elfcount;

  printf("Part 1 %s %ld %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  vec2 elves[SIZE];
  u16 elfcount = parse(file, elves);

  u32 result = 0;
  for (u16 round = 0; 1; round++) {
    if (move(elves, elfcount, round) == 0) {
      result = round + 1;
      break;
    }
  }

  printf("Part 2 %s %ld %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/23/example.txt");
  part1("2022/23/input.txt");
  part2("2022/23/example.txt");
  part2("2022/23/input.txt");
  return 0;
}