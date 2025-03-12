#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void part1(const char* name) {
  FILE* file = fopen(name, "r");
  time_t start = time(NULL);

  int opendirs[10];
  int depth = 0;
  int dirsize[200] = {0};
  int dircount = 0;
  char line[100];
  while (fgets(line, sizeof line, file)) {
    if (line[0] == '$') {
      if (line[2] == 'c') {
        if (line[5] == '.') {
          depth--;
        } else {
          opendirs[depth] = dircount;
          dircount++;
          depth++;
          assert(dircount < 200);
        }
      }

    } else if (line[0] != 'd') {
      int size;
      sscanf(line, "%d ", &size);
      for (int i = 0; i < depth; i++) {
        dirsize[opendirs[i]] += size;
      }
    }
  }

  int result = 0;
  for (int i = 0; i < dircount; i++) {
    if (dirsize[i] <= 100000) {
      result += dirsize[i];
    }
  }

  printf("Part 1 %s %d %.0lfms\n", name, result,
         difftime(time(NULL), start) / 1000);
}

int asc(const void* a, const void* b) {
  return (*(int*)a - *(int*)b);
}

void part2(const char* name) {
  FILE* file = fopen(name, "r");
  time_t start = time(NULL);

  int opendirs[10];
  int depth = 0;
  int dirsize[200] = {0};
  int dircount = 0;
  char line[100];
  while (fgets(line, sizeof line, file)) {
    if (line[0] == '$') {
      if (line[2] == 'c') {
        if (line[5] == '.') {
          depth--;
        } else {
          opendirs[depth] = dircount;
          dircount++;
          depth++;
          assert(dircount < 200);
        }
      }

    } else if (line[0] != 'd') {
      int size;
      sscanf(line, "%d ", &size);
      for (int i = 0; i < depth; i++) {
        dirsize[opendirs[i]] += size;
      }
    }
  }

  int totalspace = 70000000;
  int requiredfreespace = 30000000;
  int currentfreespace = totalspace - dirsize[0];
  qsort(dirsize, dircount, sizeof(dirsize[0]), asc);
  int result = 0;
  for (int i = 0; i < dircount; i++) {
    if (currentfreespace + dirsize[i] >= requiredfreespace) {
      result = dirsize[i];
      break;
    }
  }

  printf("Part 2 %s %d %.0lfms\n", name, result,
         difftime(time(NULL), start) / 1000);
}

int main(void) {
  part1("2022/07/example.txt");
  part1("2022/07/input.txt");
  part2("2022/07/example.txt");
  part2("2022/07/input.txt");
  return 0;
}