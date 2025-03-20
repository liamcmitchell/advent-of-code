#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SIZE 51

typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;

struct valve {
  char name[3];
  u8 flowrate;
  u8 tunnels[5];
  u8 tunnelcount;
  u8 distances[SIZE];
};

struct valves {
  struct valve items[SIZE];
  u8 len;
  u8 clen;
};

u8 valvei(const char* name, struct valves* valves) {
  for (u8 i = 0; i < valves->len; i++) {
    if (strcmp(valves->items[i].name, name) == 0) {
      return i;
    }
  }
  strcpy(valves->items[valves->len].name, name);
  valves->len++;
  return valves->len - 1;
}

void parse(FILE* file, struct valves* valves) {
  valves->len = 0;

  char namebuf[3];
  u8 flowrate;
  char tunnelsbuf[20];
  while (fscanf(file, " Valve %s has flow rate=%hhd; %*[^A-Z] %[^\n] ", namebuf,
                &flowrate, tunnelsbuf) != EOF) {
    u8 i = valvei(namebuf, valves);
    valves->items[i].flowrate = flowrate;
    valves->items[i].tunnelcount = 0;
    char* valve = strtok(tunnelsbuf, ", ");
    while (valve) {
      valves->items[i].tunnels[valves->items[i].tunnelcount++] =
          valvei(valve, valves);
      valve = strtok(NULL, ", ");
    }
  }

  // Pre-calc distances.
  for (u8 i = 0; i < valves->len; i++) {
    bool seen[SIZE] = {false};
    seen[i] = true;
    struct path {
      u8 valve;
      u8 distance;
    };
    struct path queue[SIZE];
    queue[0].valve = i;
    queue[0].distance = 0;
    u8 qh = 0;
    u8 qt = 1;
    while (qh < qt) {
      struct path* path = &queue[qh++];
      struct valve* valve = &valves->items[path->valve];

      valves->items[i].distances[path->valve] = path->distance;

      for (u8 i = 0; i < valve->tunnelcount; i++) {
        u8 next = valve->tunnels[i];
        if (seen[next])
          continue;
        seen[next] = true;
        queue[qt].valve = next;
        queue[qt].distance = path->distance + 1;
        qt++;
      }
    }
  }

  // Compress
  u8 h = 0;
  u8 t = valves->len - 1;
  while (1) {
    while (valves->items[h].flowrate) {
      h++;
    }
    while (valves->items[t].flowrate == 0) {
      t--;
    }
    if (h >= t) {
      break;
    }
    for (u8 i = 0; i < valves->len; i++) {
      u8 distance = valves->items[i].distances[h];
      valves->items[i].distances[h] = valves->items[i].distances[t];
      valves->items[i].distances[t] = distance;
    }
    struct valve valve = valves->items[h];
    valves->items[h] = valves->items[t];
    valves->items[t] = valve;
  }
  valves->clen = h;
  assert(h <= 32);
}

u16 release(u8 current, u8 minutes, u32 open, struct valves* valves) {
  u16 bestscore = 0;

  if (minutes <= 2)
    return bestscore;

  for (u8 i = 0; i < valves->clen; i++) {
    u32 mask = 1 << i;
    u8 distance = valves->items[current].distances[i];
    if (open & mask || valves->items[i].flowrate == 0 ||
        distance + 1 >= minutes)
      continue;
    u16 nextminutes = minutes - distance - 1;
    u16 score = valves->items[i].flowrate * nextminutes +
                release(i, nextminutes, open | mask, valves);
    if (score > bestscore) {
      bestscore = score;
    }
  }

  return bestscore;
}

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct valves valves;
  parse(file, &valves);
  u16 result = release(valvei("AA", &valves), 30, 0, &valves);

  printf("Part 1 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

u16 release2(u8 ai, u8 am, u8 bi, u8 bm, u32 open, struct valves* valves) {
  if (am <= 2 && bm <= 2)
    return 0;

  u8 currenti = ai;
  u8 currentm = am;
  u8 otheri = bi;
  u8 otherm = bm;
  if (currentm < otherm) {
    currenti = bi;
    currentm = bm;
    otheri = ai;
    otherm = am;
  }

  u16 bestscore = 0;

  for (u8 i = 0; i < valves->clen; i++) {
    u32 mask = 1 << i;
    u8 distance = valves->items[currenti].distances[i];
    if (open & mask || valves->items[i].flowrate == 0 ||
        distance + 1 >= currentm)
      continue;
    u16 nextm = currentm - distance - 1;
    u16 score = valves->items[i].flowrate * nextm +
                release2(i, nextm, otheri, otherm, open | mask, valves);
    if (score > bestscore) {
      bestscore = score;
    }
  }

  return bestscore;
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct valves valves;
  parse(file, &valves);
  u8 starti = valvei("AA", &valves);
  u16 result = release2(starti, 26, starti, 26, 0, &valves);

  printf("Part 2 %s %d %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/16/example.txt");
  part1("2022/16/input.txt");
  part2("2022/16/example.txt");
  part2("2022/16/input.txt");
  return 0;
}