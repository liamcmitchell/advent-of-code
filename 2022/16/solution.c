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
  assert(h <= 16);
}

u16 release(u8 current, u8 minutes, u16 open, struct valves* valves) {
  u16 bestscore = 0;

  if (minutes <= 2)
    return bestscore;

  for (u8 i = 0; i < valves->clen; i++) {
    u16 mask = 1 << i;
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

void release2(u8 current,
              u8 minutes,
              u16 open,
              u16 score,
              struct valves* valves,
              u16* scores) {
  if (minutes <= 2)
    return;

  if (scores[open] < score) {
    scores[open] = score;
  }

  for (u8 i = 0; i < valves->clen; i++) {
    u16 mask = 1 << i;
    u8 distance = valves->items[current].distances[i];
    if (open & mask || distance + 1 >= minutes)
      continue;
    u16 nextminutes = minutes - distance - 1;
    u16 nextscore = score + valves->items[i].flowrate * nextminutes;
    release2(i, nextminutes, open | mask, nextscore, valves, scores);
  }
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct valves valves;
  parse(file, &valves);
  u16 scores[66000] = {0};
  release2(valvei("AA", &valves), 26, 0, 0, &valves, scores);
  u16 result = 0;
  u16 max = 1 << valves.clen;
  for (u16 i = 0; i < max - 1; i++) {
    // Assuming pressure released will be roughly equal,
    // skip scores unlikely to produce a better result.
    if (scores[i] < result / 3)
      continue;

    for (u16 j = i + 1; j < max; j++) {
      if ((i & j) == 0 && scores[i] + scores[j] > result) {
        result = scores[i] + scores[j];
      }
    }
  }

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