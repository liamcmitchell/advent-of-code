#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef unsigned char u8;
typedef unsigned long int u32;
typedef signed long int i32;

struct range {
  i32 start;
  i32 end;
};

struct beacon {
  i32 x;
  i32 y;
};

int comparerange(const void* a, const void* b) {
  struct range* sa = (struct range*)a;
  struct range* sb = (struct range*)b;
  if (sa->start < sb->start) {
    return -1;
  } else {
    return 1;
  }
};

i32 max(i32 a, i32 b) {
  if (a > b) {
    return a;
  } else {
    return b;
  }
}

void part1(const char* name, i32 testy) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct range ranges[32];
  u8 rangecount = 0;

  struct beacon beacons[32];
  u8 beaconcount = 0;

  i32 sx, sy, bx, by;
  while (fscanf(file,
                " Sensor at x=%ld, y=%ld: closest beacon is at x=%ld, y=%ld ",
                &sx, &sy, &bx, &by) != EOF) {
    i32 radius = labs(sx - bx) + labs(sy - by);
    i32 dy = labs(sy - testy);
    i32 diff = radius - dy;
    if (diff >= 0) {
      ranges[rangecount].start = sx - diff;
      ranges[rangecount].end = sx + 1 + diff;
      rangecount++;
    }
    for (u8 i = 0; i < beaconcount; i++) {
      if (beacons[i].x == bx && beacons[i].y == by) {
        // Already have this
        goto next;
      }
    }
    beacons[beaconcount].x = bx;
    beacons[beaconcount].y = by;
    beaconcount++;

  next:
    continue;
  }

  i32 result = 0;

  // Add ranges.
  qsort(ranges, rangecount, sizeof ranges[0], comparerange);
  for (u8 i = 0; i < rangecount; i++) {
    i32 start = ranges[i].start;
    i32 end = ranges[i].end;
    while (i + 1 < rangecount && ranges[i + 1].start <= end) {
      i++;
      end = max(end, ranges[i].end);
    }
    result += end - start;
  }

  // Subtract beacons.
  for (u8 i = 0; i < beaconcount; i++) {
    if (beacons[i].y == testy) {
      result--;
    }
  }

  printf("Part 1 %s %li %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

struct sensor {
  i32 x;
  i32 y;
  i32 r;
};

void part2(const char* name, i32 maxcoord) {
  FILE* file = fopen(name, "r");
  clock_t start = clock();

  struct sensor sensors[32];
  u8 sensorcount = 0;

  i32 sx, sy, bx, by;
  while (fscanf(file,
                " Sensor at x=%ld, y=%ld: closest beacon is at x=%ld, y=%ld ",
                &sx, &sy, &bx, &by) != EOF) {
    sensors[sensorcount].x = sx;
    sensors[sensorcount].y = sy;
    sensors[sensorcount].r = labs(sx - bx) + labs(sy - by);
    sensorcount++;
  }

  // Each sensor is a diamond with 4 sides (2x positive slopes, 2x negative).
  // The missing beacon must be on the intersection of a positive and negative
  // slope.
  i32 positivelines[64];
  u8 positivecount = 0;
  i32 negativelines[64];
  u8 negativecount = 0;

  for (u8 i = 0; i < sensorcount - 1; i++) {
    positivelines[positivecount++] =
        sensors[i].y + (sensors[i].r + 1) - sensors[i].x;
    positivelines[positivecount++] =
        sensors[i].y + (sensors[i].r + 1) * -1 - sensors[i].x;
    negativelines[negativecount++] =
        sensors[i].y + (sensors[i].r + 1) + sensors[i].x;
    negativelines[negativecount++] =
        sensors[i].y + (sensors[i].r + 1) * -1 + sensors[i].x;
  }

  i32 result = 0;
  for (u8 p = 0; p < positivecount; p++) {
    for (u8 n = 0; n < negativecount; n++) {
      // https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Given_two_line_equations
      i32 px = (negativelines[n] - positivelines[p]) / (1 - -1);
      i32 py = px + positivelines[p];

      if (px < 0 || px > maxcoord || py < 0 || py > maxcoord) {
        continue;
      }

      // Check distance from all sensors.
      for (u8 i = 0; i < sensorcount; i++) {
        i32 dx = sensors[i].x - px;
        i32 dy = sensors[i].y - py;
        i32 dist = ((labs(dx) + labs(dy)) - sensors[i].r);
        if (dist <= 0) {
          goto next;
        }
      }

      result = px * 4000000 + py;
      goto result;

    next:
      continue;
    }
  }

result:
  printf("Part 2 %s %li %lums\n", name, result,
         (clock() - start) / (CLOCKS_PER_SEC / 1000));
}

int main(void) {
  part1("2022/15/example.txt", 10);
  part1("2022/15/input.txt", 2000000);
  part2("2022/15/example.txt", 20);
  part2("2022/15/input.txt", 4000000);
  return 0;
}