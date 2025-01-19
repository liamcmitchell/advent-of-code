package main

import (
	"fmt"
	"os"
	"path"
	"time"
)

func part1(name string) {
	raw, _ := os.ReadFile(name)
	start := time.Now()

	input := string(raw)
	seeds := make([]int, 0, 100)
	mapped := map[int]bool{}
	haveNumber := false
	number := 0
	numberIdx := 0
	firstLine := true
	destStart := 0
	sourceStart := 0
	rangeLen := 0
	for _, char := range input {
		if char >= '0' && char <= '9' {
			number = number*10 + int(char-'0')
			haveNumber = true
		} else if haveNumber {
			if firstLine {
				seeds = append(seeds, number)
			} else if numberIdx == 0 {
				destStart = number
			} else if numberIdx == 1 {
				sourceStart = number
			} else if numberIdx == 2 {
				rangeLen = number
			}
			number = 0
			haveNumber = false
			numberIdx++
		}
		if char == ':' {
			mapped = map[int]bool{}
		}
		if char == '\n' {
			if rangeLen > 0 {
				for idx, seed := range seeds {
					if seed >= sourceStart && seed < sourceStart+rangeLen && !mapped[idx] {
						seeds[idx] = destStart + (seed - sourceStart)
						mapped[idx] = true
					}
				}
			}
			numberIdx = 0
			firstLine = false
			destStart = 0
			sourceStart = 0
			rangeLen = 0
		}
	}
	for idx, seed := range seeds {
		if seed >= sourceStart && seed < sourceStart+rangeLen && !mapped[idx] {
			seeds[idx] = destStart + (seed - sourceStart)
		}
	}

	lowest := seeds[0]
	for _, seed := range seeds {
		if seed < lowest {
			lowest = seed
		}
	}

	fmt.Println("Part 1", path.Base(name), lowest, time.Now().Sub(start).String())
}

type SeedRange struct {
	start int
	len   int
}

func part2(name string) {
	raw, _ := os.ReadFile(name)
	start := time.Now()

	input := string(raw)
	seedRanges := make([]SeedRange, 0, 100)
	mapped := map[int]bool{}
	haveNumber := false
	number := 0
	numberIdx := 0
	firstLine := true
	destStart := 0
	sourceStart := 0
	rangeLen := 0
	for _, char := range input {
		if char >= '0' && char <= '9' {
			number = number*10 + int(char-'0')
			haveNumber = true
		} else if haveNumber {
			if firstLine {
				if numberIdx%2 == 0 {
					seedRanges = append(seedRanges, SeedRange{start: number})
				} else {
					seedRanges[len(seedRanges)-1].len = number
				}
			} else if numberIdx == 0 {
				destStart = number
			} else if numberIdx == 1 {
				sourceStart = number
			} else if numberIdx == 2 {
				rangeLen = number
			}
			number = 0
			haveNumber = false
			numberIdx++
		}
		if char == ':' {
			mapped = map[int]bool{}
		}
		if char == '\n' {
			if rangeLen > 0 {
				for idx, seedRange := range seedRanges {
					seedsEnd := seedRange.start + seedRange.len
					sourceEnd := sourceStart + rangeLen
					if !mapped[idx] && !(seedRange.start >= sourceEnd || seedsEnd <= sourceStart) {
						toMoveStart := max(seedRange.start, sourceStart)
						toMoveEnd := min(seedsEnd, sourceEnd)

						seedRanges[idx].start = toMoveStart + destStart - sourceStart
						seedRanges[idx].len = toMoveEnd - toMoveStart

						if toMoveStart > seedRange.start {
							seedRanges = append(seedRanges, SeedRange{start: seedRange.start, len: toMoveStart - seedRange.start})
						}
						if toMoveEnd < seedsEnd {
							seedRanges = append(seedRanges, SeedRange{start: toMoveEnd, len: seedsEnd - toMoveEnd})
						}

						mapped[idx] = true
					}
				}
			}
			numberIdx = 0
			firstLine = false
			destStart = 0
			sourceStart = 0
			rangeLen = 0
		}
	}
	for idx, seedRange := range seedRanges {
		seedsEnd := seedRange.start + seedRange.len
		sourceEnd := sourceStart + rangeLen
		if !mapped[idx] && !(seedRange.start >= sourceEnd || seedsEnd <= sourceStart) {
			toMoveStart := max(seedRange.start, sourceStart)
			toMoveEnd := min(seedsEnd, sourceEnd)

			seedRanges[idx].start = toMoveStart + destStart - sourceStart
			seedRanges[idx].len = toMoveEnd - toMoveStart

			if toMoveStart > seedRange.start {
				seedRanges = append(seedRanges, SeedRange{start: seedRange.start, len: toMoveStart - seedRange.start})
			}
			if toMoveEnd < seedsEnd {
				seedRanges = append(seedRanges, SeedRange{start: toMoveEnd, len: seedsEnd - toMoveEnd})
			}

			mapped[idx] = true
		}
	}

	lowest := seedRanges[0].start
	for _, seeds := range seedRanges {
		if seeds.start < lowest {
			lowest = seeds.start
		}
	}

	fmt.Println("Part 2", path.Base(name), lowest, time.Now().Sub(start).String())
}

func main() {
	part1("2023/05/example.txt")
	part1("2023/05/input.txt")
	part2("2023/05/example.txt")
	part2("2023/05/input.txt")
}
