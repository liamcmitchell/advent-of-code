#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define ROCKS 5
#define LAYERS 256
#define GUSTS 11000
#define STEPS 10

typedef unsigned char u8;
typedef unsigned long int u32;
typedef unsigned long long int u64;

struct rock {
  u8 width;
  u8 height;
  // Shapes are encoded with u8 layers from bottom to top.
  // Least significant bit == left side.
  u8 layers[4];
};
struct rock rocks[ROCKS] = {
    {4, 1, {15}},         {3, 3, {2, 7, 2}}, {3, 3, {7, 4, 4}},
    {1, 4, {1, 1, 1, 1}}, {2, 2, {3, 3}},
};

// Tower only keeps a small number of layers.
// We regularly check if the layers are filling,
// move the top layers back to the start and update offset.
// The offset tells us the height of layers[0].
struct tower {
  u8 layers[LAYERS];
  u64 offset;
  u64 height;
};

bool collides(u8 x, u64 y, struct rock* rock, struct tower* tower) {
  u8 dy = 0;
  while (dy < rock->height && y + dy < tower->height) {
    if ((rock->layers[dy] << x) & tower->layers[y - tower->offset + dy]) {
      return true;
    }
    dy++;
  }

  return false;
}

void compress(struct tower* tower) {
  if (tower->height - tower->offset + 20 < LAYERS)
    return;

  u8 end = tower->height - tower->offset;
  u8 start = end;
  u8 seen = 0;
  while (start > 0 && seen != 127) {
    start--;
    seen |= tower->layers[start];
  }
  if (start < 10) {
    return;
  } else {
    start -= 10;
  }
  u8 count = end - start;
  memcpy(tower->layers, &tower->layers[start], count * sizeof tower->layers[0]);
  memset(&tower->layers[count], 0, (LAYERS - count) * sizeof tower->layers[0]);
  tower->offset += start;
}

void stop(u8 x, u64 y, struct rock* rock, struct tower* tower) {
  u8 dy = 0;
  while (dy < rock->height) {
    tower->layers[y - tower->offset + dy] |= rock->layers[dy] << x;
    dy++;
  }
  if (y + dy > tower->height) {
    tower->height = y + dy;
    compress(tower);
  }
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  char gusts[GUSTS];
  u32 gustcount = fread(gusts, sizeof(char), GUSTS, file);

  struct tower tower = {{0}, 0, 0};
  u64 rocki = 0;
  u64 gusti = 0;
  while (rocki < 2022) {
    struct rock* rock = &rocks[rocki++ % ROCKS];
    u8 x = 2;
    u64 y = tower.height + 3;
    while (1) {
      char gust = gusts[gusti++ % gustcount];
      if (gust == '<' && x > 0 && !collides(x - 1, y, rock, &tower))
        x--;
      if (gust == '>' && x + rock->width < 7 &&
          !collides(x + 1, y, rock, &tower))
        x++;
      if (y == 0 || collides(x, y - 1, rock, &tower)) {
        stop(x, y, rock, &tower);
        break;
      } else {
        y--;
      }
    }
  }

  u64 result = tower.height;

  printf("Part 1 %s %llu %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  char gusts[GUSTS];
  u32 gustcount = fread(gusts, sizeof(char), GUSTS, file);

  struct tower tower = {{0}, 0, 0};
  u64 rocki = 0;
  u64 gusti = 0;
  u64 targetrocks = 1000000000000;

  // Same as above but look for where the rock/step/gust patterns repeat.
  // They don't repeat cleanly on the appearance of a new rock.
  // We look for them in the inner loop and record them by rock/step.
  struct repeat {
    u8 count;
    u64 heights[3];
    u64 rocks[3];
  };
  struct repeat repeats[ROCKS][STEPS] = {{{0, {0}, {0}}}};
  bool searching = true;

  while (rocki < targetrocks) {
    struct rock* rock = &rocks[rocki++ % ROCKS];
    u8 x = 2;
    u64 y = tower.height + 3;
    u8 step = 0;
    while (1) {
      if (searching && step++ < STEPS && (gusti % gustcount) == 0) {
        u8 ri = (rocki - 1) % ROCKS;
        struct repeat* repeat = &repeats[ri][step];
        repeat->heights[repeat->count] = tower.height;
        repeat->rocks[repeat->count] = rocki;
        repeat->count++;
        // Once we have 3 repeats, we can skip ahead.
        if (repeat->count == 3) {
          searching = false;
          u64 heightdiff = repeat->heights[1] - repeat->heights[0];
          assert(repeat->heights[2] - repeat->heights[1] == heightdiff);
          u64 rockdiff = repeat->rocks[1] - repeat->rocks[0];
          assert(repeat->rocks[2] - repeat->rocks[1] == rockdiff);
          u64 remaining = (targetrocks - rocki) / rockdiff;
          rocki += remaining * rockdiff;
          y += remaining * heightdiff;
          tower.height += remaining * heightdiff;
          tower.offset += remaining * heightdiff;
        }
      }

      char gust = gusts[gusti++ % gustcount];
      if (gust == '<' && x > 0 && !collides(x - 1, y, rock, &tower))
        x--;
      if (gust == '>' && x + rock->width < 7 &&
          !collides(x + 1, y, rock, &tower))
        x++;
      if (y == 0 || collides(x, y - 1, rock, &tower)) {
        stop(x, y, rock, &tower);
        break;
      } else {
        y--;
      }
    }
  }

  u64 result = tower.height;

  printf("Part 2 %s %llu %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/17/example.txt");
  part1("2022/17/input.txt");
  part2("2022/17/example.txt");
  part2("2022/17/input.txt");
  return 0;
}