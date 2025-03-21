#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SIZE 30
#define MATERIALS 4

typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;

enum material { ORE, CLAY, OBSIDIAN, GEODE };

typedef u16 counts[MATERIALS];
typedef counts blueprint[MATERIALS];

u8 parse(FILE* file, blueprint* blueprints) {
  u8 blueprintcount = 0;

  while (fscanf(file,
                " Blueprint %*d: Each ore robot costs %hd ore. Each clay robot "
                "costs %hd ore. Each obsidian robot costs %hd ore and %hd "
                "clay. Each geode robot costs %hd ore and %hd obsidian. ",
                &blueprints[blueprintcount][ORE][ORE],
                &blueprints[blueprintcount][CLAY][ORE],
                &blueprints[blueprintcount][OBSIDIAN][ORE],
                &blueprints[blueprintcount][OBSIDIAN][CLAY],
                &blueprints[blueprintcount][GEODE][ORE],
                &blueprints[blueprintcount][GEODE][OBSIDIAN]) != EOF) {
    blueprintcount++;
  }

  return blueprintcount;
}

void add(counts out, counts a, counts b) {
  for (u8 i = 0; i < MATERIALS; i++) {
    out[i] = a[i] + b[i];
  }
}

void subtract(counts out, counts a, counts b) {
  for (u8 i = 0; i < MATERIALS; i++) {
    out[i] = a[i] - b[i];
  }
}

void scale(counts out, counts a, u8 factor) {
  for (u8 i = 0; i < MATERIALS; i++) {
    out[i] = a[i] * factor;
  }
}

// Max robots needed for each material.
void max(counts out, blueprint blueprint) {
  for (u8 i = 0; i < MATERIALS; i++) {
    for (u8 j = 0; j < MATERIALS; j++) {
      if (out[j] < blueprint[i][j] && i != j) {
        out[j] = blueprint[i][j];
      }
    }
  }
}

// Time until next robot is made, 0 if not possible.
u8 waittime(counts costs, counts robots, counts materials) {
  u8 time = 1;
  for (u8 i = 0; i < MATERIALS; i++) {
    if (costs[i] == 0 || materials[i] >= costs[i])
      continue;
    if (robots[i] == 0)
      return 0;
    u8 materialtime = 1 + (costs[i] - materials[i] + robots[i] - 1) / robots[i];
    if (materialtime > time) {
      time = materialtime;
    }
  }
  return time;
}

u16 geodes(blueprint blueprint,
           counts maxrobots,
           counts robots,
           counts materials,
           u8 time) {
  if (time == 0) {
    return materials[GEODE];
  }

  counts nextmaterials, nextrobots;
  u16 best = 0;

  // Consider making a robot for each material.
  for (u8 i = 0; i < MATERIALS; i++) {
    // Only needed if we are under max and don't already have materials.
    bool needed = robots[i] < maxrobots[i] && materials[i] < maxrobots[i];

    if (i != GEODE && !needed)
      continue;

    u8 wait = waittime(blueprint[i], robots, materials);

    if (wait == 0 || wait > time)
      continue;

    scale(nextmaterials, robots, wait);
    add(nextmaterials, nextmaterials, materials);
    subtract(nextmaterials, nextmaterials, blueprint[i]);
    memcpy(nextrobots, robots, sizeof(counts));
    nextrobots[i]++;
    u16 score =
        geodes(blueprint, maxrobots, nextrobots, nextmaterials, time - wait);
    if (score > best) {
      best = score;
    }
  }

  if (best == 0) {
    best = materials[GEODE] + robots[GEODE] * time;
  }

  return best;
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  blueprint blueprints[SIZE] = {{{0}}};
  u8 blueprintcount = parse(file, blueprints);

  u16 result = 0;
  for (u8 i = 0; i < blueprintcount; i++) {
    counts maxrobots;
    max(maxrobots, blueprints[i]);
    counts robots = {1};
    counts materials = {0};
    u16 score = geodes(blueprints[i], maxrobots, robots, materials, 24);
    result += (i + 1) * score;
  }

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  blueprint blueprints[SIZE] = {{{0}}};
  u8 blueprintcount = parse(file, blueprints);

  if (blueprintcount > 3) {
    blueprintcount = 3;
  }

  u16 result = 1;
  for (u8 i = 0; i < blueprintcount; i++) {
    counts maxrobots;
    max(maxrobots, blueprints[i]);
    counts robots = {1};
    counts materials = {0};
    u16 score = geodes(blueprints[i], maxrobots, robots, materials, 32);
    result = result * score;
  }

  printf("Part 2 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  // Example linebreaks changed to match input.
  part1("2022/19/example.txt");
  part1("2022/19/input.txt");
  part2("2022/19/example.txt");
  part2("2022/19/input.txt");
  return 0;
}